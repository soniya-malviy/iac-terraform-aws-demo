# Lab 06 - Drift Detection

## Learning Objective

Understand **configuration drift** -- what happens when real infrastructure no longer matches the Terraform code -- and how `terraform plan` detects it.

---

## The Scenario

It is 2 AM. An incident is happening. A well-meaning engineer logs into the AWS Console and manually changes a security group to allow all traffic (0.0.0.0/0 on all ports). The fire is out. But now your infrastructure does not match your code.

**This is drift.**

Drift is one of the most common and dangerous problems in infrastructure management. It happens silently, accumulates over time, and eventually turns your "Infrastructure as Code" into "Infrastructure as Suggestion."

In this lab you will deliberately create drift, watch Terraform catch it, and then fix it.

---

## Exercises

### Exercise 1 -- Deploy the Baseline

Initialize and apply the provided `main.tf`. This creates:

- An S3 bucket with specific tags (`Environment`, `Team`, `ManagedBy`)
- A security group in the default VPC with a single inbound rule: SSH (port 22) from `10.0.0.0/8`

```bash
terraform init
terraform apply
```

Review the output. Note the tags on the bucket and the security group rules. This is your **desired state** -- the single source of truth.

> **Tip:** Copy the S3 bucket name and security group ID from the apply output. You will need them in the next exercise.

---

### Exercise 2 -- Be the Cowboy Admin

Now play the role of the engineer at 2 AM. Log into the **AWS Console** and make two manual changes:

**Change 1 -- Add a tag to the S3 bucket:**

1. Go to S3 in the AWS Console.
2. Click on your bucket.
3. Go to the Properties tab and find Tags.
4. Add a new tag: Key = `ManuallyAdded`, Value = `true`.
5. Save.

**Change 2 -- Add an overly permissive security group rule:**

1. Go to EC2 > Security Groups in the AWS Console.
2. Find the security group created by Terraform (look for the name containing your project name).
3. Click Edit inbound rules.
4. Add a new rule: Type = All traffic, Source = 0.0.0.0/0 (Anywhere).
5. Save.

Your infrastructure now has changes that are **not reflected in your code**. This is drift.

> **No console access?** See Exercise 6 below for AWS CLI alternatives, or refer to `drift-commands.md`.

---

### Exercise 3 -- Detect the Drift

Run a plan:

```bash
terraform plan
```

Read the output carefully. Terraform detected **both** manual changes and wants to revert them:

- The extra tag `ManuallyAdded` on the S3 bucket shows with a `-` (minus), meaning Terraform will **remove** it.
- The extra "allow all traffic" inbound rule on the security group shows with a `-`, meaning Terraform will **remove** it.

The plan summary will say something like `0 to add, 2 to change, 0 to destroy`. Terraform is not creating or destroying anything -- it is **updating** the resources to match the code.

This is **drift detection**. Terraform compared the desired state (your code) with the actual state (what exists in AWS) and found differences.

---

### Exercise 4 -- Reconcile the Drift

Apply the plan to bring reality back in line with the code:

```bash
terraform apply
```

Type `yes` when prompted. The manual changes are gone. The infrastructure matches the code again.

This is called **reconciliation**. Terraform enforced the desired state and removed the unauthorized changes.

Run `terraform plan` one more time to confirm:

```
No changes. Your infrastructure matches the configuration.
```

---

### Exercise 5 -- Refresh Without Changing

There is another approach: updating the **state** to match reality, without changing the infrastructure itself.

Run:

```bash
terraform plan -refresh-only
```

This tells Terraform: "Look at what actually exists in AWS and update my state file to match, but do not change any infrastructure."

This is useful when:

- You want to see what has drifted without reverting anything yet.
- Another tool or process made a legitimate change and you want Terraform to "acknowledge" it before deciding what to do.
- You are auditing drift across many environments.

> **Note:** The older `terraform refresh` command does the same thing but is now considered legacy. Prefer `terraform plan -refresh-only` because it shows you what will change in the state before you approve it.

If you want to actually apply the refresh:

```bash
terraform apply -refresh-only
```

---

### Exercise 6 (Alternative) -- Create Drift via AWS CLI

If you do not have AWS Console access, you can create the same drift using the CLI. Replace the placeholder values with your actual resource names.

**Add a tag to the S3 bucket:**

```bash
aws s3api put-bucket-tagging \
  --bucket YOUR_BUCKET_NAME \
  --tagging 'TagSet=[{Key=Environment,Value=production},{Key=Team,Value=platform},{Key=ManagedBy,Value=terraform},{Key=ManuallyAdded,Value=true}]'
```

> **Important:** `put-bucket-tagging` replaces all tags, so you must include the original tags plus the new one.

**Add an overly permissive security group rule:**

```bash
aws ec2 authorize-security-group-ingress \
  --group-id YOUR_SECURITY_GROUP_ID \
  --protocol -1 \
  --cidr 0.0.0.0/0
```

**Verify the drift:**

```bash
aws s3api get-bucket-tagging --bucket YOUR_BUCKET_NAME
aws ec2 describe-security-groups --group-ids YOUR_SECURITY_GROUP_ID
```

Now go back to Exercise 3 and run `terraform plan` to detect the drift.

> **Tip:** See `drift-commands.md` for a complete reference of these commands.

---

## Discussion

**Should you always revert drift?**

Not necessarily. What if the manual change was correct? What if that 2 AM security group change was the right fix for the incident?

In that case, you should **update the code to match the infrastructure**, not revert the infrastructure. The goal is not "code always wins" -- the goal is "code and reality always match."

The workflow is:

1. Detect the drift with `terraform plan`.
2. **Decide:** Was the manual change correct or incorrect?
3. If incorrect: run `terraform apply` to revert it.
4. If correct: update your `.tf` files to include the change, then run `terraform plan` to confirm zero diff.

Either way, you end up in the same place: code and reality in sync.

---

## Clean Up

```bash
terraform destroy
```

Type `yes` when prompted.

---

## Key Takeaway

> Your Terraform code is the **single source of truth**. If reality does not match the code, either fix reality or fix the code -- never leave them out of sync.

---

## Summary

| Concept | What You Learned |
|---|---|
| **Configuration Drift** | When real infrastructure diverges from the code that defines it |
| **Drift Detection** | `terraform plan` compares desired state to actual state and reports differences |
| **Reconciliation** | `terraform apply` reverts drift by enforcing the desired state |
| **Refresh** | `terraform plan -refresh-only` updates the state to match reality without changing infrastructure |
| **Single Source of Truth** | Code and reality must always match -- fix one or the other, never leave them out of sync |
