# Lab 04 - Variables and Outputs

## Learning Objective

Use **variables** to make Terraform configs reusable across environments, and **outputs** to extract useful information from your infrastructure.

---

## Key Concepts

Hardcoding values is the enemy of reusability. What if you need the same infrastructure in dev and prod? You would have to copy files and change strings by hand -- a recipe for drift and mistakes.

**Variables** let you parameterize your configuration. Write the code once, then pass in different values for each environment.

**Outputs** let you extract information from your infrastructure after it is created -- things like ARNs, IP addresses, and DNS names that you might need in other systems or downstream configs.

### Variable Definition

Variables are declared in a `variables.tf` file with a name, type, description, and optional default:

```hcl
variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = "dev"
}
```

### Variable Usage

Reference variables in your config with `var.<name>`:

```hcl
tags = {
  Environment = var.environment
}
```

### String Interpolation

Combine variables with other strings using `${}` inside double quotes:

```hcl
bucket = "${var.project_name}-${var.environment}-data"
```

### Variable Precedence (lowest to highest)

1. Default value in the variable block
2. `terraform.tfvars` file
3. `*.auto.tfvars` files
4. `-var` flag on the command line

---

## Exercises

### Exercise 1 -- Apply the Hardcoded Config

Look at the `main.tf` in this directory. Notice that everything is hardcoded -- the region, bucket name, project name, and environment are all literal strings.

```bash
terraform init
terraform apply
```

This works, but imagine you need a staging environment. You would have to copy the file and change every "dev" to "staging" by hand. That does not scale.

---

### Exercise 2 -- Create variables.tf

Create a file called `variables.tf` in this directory with three variables:

| Variable       | Type   | Default        | Description                         |
|----------------|--------|----------------|-------------------------------------|
| `environment`  | string | `"dev"`        | Deployment environment (dev/staging/prod) |
| `project_name` | string | `"shopsmart"`  | Project name used in resource naming |
| `region`       | string | `"us-east-1"`  | AWS region for all resources        |

> **Hint:** Check `solution/variables.tf` if you need a reference.

---

### Exercise 3 -- Parameterize main.tf

Update `main.tf` to replace every hardcoded value with a variable reference:

- The provider region becomes `var.region`
- The bucket name becomes `"${var.project_name}-${var.environment}-data"`
- The tags use `var.environment` and `var.project_name`

Run `terraform plan` -- it should show **no changes**, because the variable defaults match the original hardcoded values.

```bash
terraform plan
```

If the plan is clean (no changes), your refactor was correct.

---

### Exercise 4 -- Create outputs.tf

Create a file called `outputs.tf` that exposes three values:

| Output          | Value                                   |
|-----------------|-----------------------------------------|
| `bucket_arn`    | `aws_s3_bucket.data.arn`                |
| `bucket_name`   | `aws_s3_bucket.data.bucket`             |
| `bucket_region` | `aws_s3_bucket.data.region`             |

Apply and observe the outputs printed at the end:

```bash
terraform apply
```

You should see something like:

```
Outputs:

bucket_arn    = "arn:aws:s3:::shopsmart-dev-data"
bucket_name   = "shopsmart-dev-data"
bucket_region = "us-east-1"
```

You can also retrieve outputs at any time with:

```bash
terraform output
terraform output bucket_arn
```

---

### Exercise 5 -- Apply with a Different Environment

Now use a command-line variable to switch environments:

```bash
terraform apply -var="environment=staging"
```

Terraform will show that it wants to **replace** the bucket because the name changed from `shopsmart-dev-data` to `shopsmart-staging-data`. This is the power of variables -- same code, different environment.

**Do not apply this** (answer "no") unless you want to actually create the staging bucket. The point is to see that one variable change ripples through the entire config.

---

### Exercise 6 -- Use a terraform.tfvars File

Instead of passing `-var` every time, create a `terraform.tfvars` file:

```hcl
environment  = "prod"
project_name = "shopsmart"
```

Now run:

```bash
terraform plan
```

Terraform automatically loads `terraform.tfvars` and uses those values. You should see it wants to change the bucket name to `shopsmart-prod-data`.

> **Note:** Check `solution/terraform.tfvars` for an example.

---

### Exercise 7 (Explore) -- Variable Precedence

What happens if you set the same variable in both `terraform.tfvars` AND the command line?

```bash
terraform plan -var="environment=staging"
```

Even though `terraform.tfvars` says `environment = "prod"`, the CLI flag wins. The bucket name in the plan will be `shopsmart-staging-data`.

**Rule:** Command-line `-var` flags always take the highest precedence.

---

## Key Takeaway

Same code, different environments. Variables are how you avoid copy-paste infrastructure. Define your config once, parameterize the parts that change, and use variables to drive dev, staging, and prod from a single codebase. Outputs give you a clean way to extract and share the information your infrastructure produces.
