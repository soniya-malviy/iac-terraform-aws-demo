# Lab 03 - Terraform State

## Learning Objective

Understand Terraform state -- what it is, why it matters, and what happens without it.

By the end of this lab you will be able to explain the purpose of `terraform.tfstate`, inspect its contents, and demonstrate what happens when state is lost or manipulated.

---

## The Analogy

> **The state file is your receipt.**
>
> If you bought something at a store and want to return it, you need the receipt. If you created infrastructure with Terraform and want to modify or destroy it, Terraform needs the state file.
>
> No receipt? The store doesn't know what you bought. No state file? Terraform doesn't know what it created.

---

## Prerequisites

- Terraform installed (v1.0+)
- AWS credentials configured (`aws configure` or environment variables)
- Completed Lab 01 and Lab 02

---

## Exercise 1 -- Inspect the State File

1. Initialize and apply the configuration:

   ```bash
   terraform init
   terraform apply -auto-approve
   ```

2. Open `terraform.tfstate` in your editor. It is a JSON file that Terraform uses as its source of truth.

3. Walk through the JSON structure. Find the following for your S3 bucket:
   - The resource's ARN (`arn:aws:s3:::...`)
   - The bucket name
   - Other attributes like `region`, `tags`, and `versioning`

4. Notice that the file also records the Terraform version, provider versions, and a serial number that increments on every change.

**Key question:** What would happen if you manually edited an attribute in this file? (Answer: Terraform would see a drift between state and reality on the next plan.)

---

## Exercise 2 -- State Commands

Terraform provides CLI commands to inspect state without opening the raw JSON.

1. List all resources Terraform is tracking:

   ```bash
   terraform state list
   ```

   You should see two resources:
   ```
   aws_s3_bucket.data_store
   aws_s3_bucket.logs
   ```

2. Show detailed state for one resource:

   ```bash
   terraform state show aws_s3_bucket.data_store
   ```

   This prints every attribute Terraform knows about that bucket -- ARN, ID, tags, region, and more.

3. Try the same for the logs bucket:

   ```bash
   terraform state show aws_s3_bucket.logs
   ```

---

## Exercise 3 -- Break It (THE KEY EXERCISE)

This is the most important exercise in this lab. You will delete the state file and see what happens.

### Step A -- Create a safety net

```bash
cp terraform.tfstate terraform.tfstate.backup-safe
```

### Step B -- Delete the state file

```bash
rm terraform.tfstate
```

### Step C -- Run plan

```bash
terraform plan
```

Look at the output. Terraform thinks **nothing exists**. It wants to **create** both buckets from scratch -- even though they are already running in AWS.

```
Plan: 2 to add, 0 to change, 0 to destroy.
```

### Step D -- Think about it

What would happen if you ran `terraform apply` right now?

- For S3 buckets: you would get an **error** because the bucket name already exists in AWS (S3 bucket names are globally unique).
- For other resource types: you might create **duplicate resources**, leading to cost, confusion, and drift.

**Do NOT apply.** Just observe the plan.

### Step E -- Restore the state file

```bash
cp terraform.tfstate.backup-safe terraform.tfstate
```

### Step F -- Verify recovery

```bash
terraform plan
```

You should see the most reassuring message in Terraform:

```
No changes. Your infrastructure matches the configuration.
```

Relief.

---

## Exercise 4 -- Remove a Resource from State

Sometimes you need to "unmanage" a resource -- tell Terraform to forget about it without destroying it in AWS.

1. Remove the data_store bucket from state:

   ```bash
   terraform state rm aws_s3_bucket.data_store
   ```

   Output:
   ```
   Removed aws_s3_bucket.data_store
   Successfully removed 1 resource instance(s).
   ```

2. Run plan:

   ```bash
   terraform plan
   ```

   Terraform wants to **create** `aws_s3_bucket.data_store` again -- because it no longer knows it already exists. The bucket is still in AWS, but Terraform has forgotten about it.

3. This is how you "unmanage" a resource. It is useful when:
   - You want to hand a resource off to another Terraform workspace
   - You imported something by mistake
   - You are migrating between state files

4. **Clean up:** Since we broke state, the easiest recovery is to restore from backup and destroy:

   ```bash
   cp terraform.tfstate.backup-safe terraform.tfstate
   terraform destroy -auto-approve
   ```

---

## Exercise 5 -- Discussion

**Why is committing `terraform.tfstate` to Git dangerous?**

Think about these risks before reading the answers:

1. **Secrets in plain text** -- State files contain every attribute of every resource, including passwords, access keys, and other sensitive values. Committing state to Git means committing secrets to version control.

2. **Merge conflicts** -- The state file changes on every apply. If two people apply at the same time and both commit, you get merge conflicts in a JSON file that is not meant to be manually merged.

3. **Stale state** -- If someone forgets to pull before running Terraform, they are working with outdated state. This can cause Terraform to overwrite or duplicate resources.

**The `.gitignore` in a Terraform project should always include:**
```
*.tfstate
*.tfstate.*
```

---

## Key Takeaway

> **State is the source of truth for what Terraform manages. Lose it, and Terraform forgets everything.**

The state file maps your configuration (`main.tf`) to real-world resources. Without it, Terraform cannot plan updates, detect drift, or destroy resources.

---

## A Note on Remote State (Production Use)

In production, you should **never** store state locally. Instead, use a **remote backend** such as:

- **S3** -- Store state in an S3 bucket for state locking (prevents two people from applying at the same time)
- **Terraform Cloud** -- Hashicorp's managed service for state storage, locking, and collaboration

We will not implement a remote backend in this lab, but know that it exists and is essential for team workflows. A future lab will cover this in detail.

Example of what a backend configuration looks like (for reference only):

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "lab-03/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
```

---

## Clean Up

If you haven't already destroyed your resources:

```bash
terraform destroy -auto-approve
```

Verify the state file is now nearly empty:

```bash
cat terraform.tfstate
```

---

## What's Next

In the next lab, we will explore variables and outputs to make configurations reusable and expose useful information after apply.
