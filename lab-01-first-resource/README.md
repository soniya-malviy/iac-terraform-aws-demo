# Lab 01 - Your First Terraform Resource

## Learning Objective

Understand **providers**, **resources**, and the **init / plan / apply** workflow by creating a single S3 bucket from scratch.

---

## Key Concepts

### Providers

Terraform is just a core engine. It doesn't know what AWS is. It uses plugins called **Providers** to translate your HCL code into API calls.

When you write `provider "aws"`, Terraform knows to download the AWS provider plugin from the Terraform Registry. That plugin contains all the logic for authenticating with AWS and calling its APIs.

### Resources

A **Resource** is the noun of your infrastructure. You declare what you want to exist. For example, `aws_s3_bucket` tells the AWS provider "I want an S3 bucket with these settings." Terraform figures out how to make it happen.

---

## Exercises

### Exercise 1 -- Write main.tf

Open `skeleton/main.tf`. It contains a template with blanks (`______`) for you to fill in.

Your job:

1. Set the provider **source** to `"hashicorp/aws"`.
2. Set the AWS **region** to `"us-east-1"`.
3. Set the **bucket name** to `"shopsmart-logs-<YOURNAME>"` (replace `<YOURNAME>` with something unique, like your first name or GitHub handle).

Copy your completed file into this directory as `main.tf` (or work directly inside `skeleton/`).

> **Hint:** If you get stuck, the completed version is in `solution/main.tf`.

---

### Exercise 2 -- terraform init

Run:

```bash
terraform init
```

**What just happened?**

- Terraform read the `required_providers` block in your code.
- It downloaded the AWS provider plugin from the Terraform Registry.
- It created a `.terraform/` directory to store that plugin.
- It created a `.terraform.lock.hcl` file to pin the exact provider version.

You should see output like:

```
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.x.x...
```

---

### Exercise 3 -- terraform plan

Run:

```bash
terraform plan
```

Read the output carefully. You will see lines prefixed with `+` (plus signs). Each `+` means Terraform **will create** something that does not yet exist.

```
  + resource "aws_s3_bucket" "shopsmart_logs" {
      + bucket = "shopsmart-logs-yourname"
      ...
    }

Plan: 1 to add, 0 to change, 0 to destroy.
```

`plan` is a dry run. Nothing has been created yet. This is your chance to review before committing.

---

### Exercise 4 -- terraform apply

Run:

```bash
terraform apply
```

Terraform will show you the same plan and then ask:

```
Do you want to perform these actions?
  Enter a value: yes
```

Type `yes` and press Enter. Terraform will now make the real AWS API call to create your S3 bucket.

Once it finishes you should see:

```
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
```

Congratulations -- you just created real cloud infrastructure with code.

---

### Exercise 5 -- terraform plan (again)

Run `terraform plan` one more time:

```bash
terraform plan
```

This time the output should say:

```
No changes. Your infrastructure matches the configuration.
```

This reinforces **idempotency** -- the concept you learned in Lab 00. Terraform compares the desired state (your code) with the actual state (what exists in AWS) and determines there is nothing to do.

---

### Exercise 6 (Explore) -- Look Under the Hood

**See the provider binary:**

```bash
ls .terraform/providers/
```

You will find the downloaded AWS provider plugin binary nested inside this directory.

**Preview the state file:**

```bash
cat terraform.tfstate
```

This JSON file is how Terraform remembers what it created. It maps your resource blocks to real AWS resource IDs. We will do a full deep-dive on state in **Lab 03** -- for now, just notice that your bucket name and ARN are recorded here.

> **Warning:** Never edit `terraform.tfstate` by hand. Never commit it to version control with secrets in it. More on this in Lab 03.

---

## Clean Up

When you are done exploring, destroy the resources so you do not incur charges:

```bash
terraform destroy
```

Type `yes` when prompted. Terraform will delete the S3 bucket it created.

Verify the destroy completed:

```
Destroy complete! Resources: 1 destroyed.
```

---

## Summary

| Concept | What You Learned |
|---|---|
| **Provider** | A plugin that lets Terraform talk to a specific cloud (AWS, Azure, GCP, etc.) |
| **Resource** | A declaration of infrastructure you want to exist |
| **terraform init** | Downloads provider plugins |
| **terraform plan** | Dry run -- shows what will change |
| **terraform apply** | Executes the plan and creates real infrastructure |
| **Idempotency** | Running apply again when nothing changed results in no actions |
