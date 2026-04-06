# Lab 02 - Change and Destroy

## Learning Objective

Understand how Terraform handles changes to infrastructure -- specifically the difference between **update-in-place** and **destroy-and-recreate** (immutable infrastructure).

## Key Concept

Not all changes are equal. Adding a tag to a bucket? Update in place. Changing a bucket name? Terraform must destroy the old one and create a new one. This is called **immutable infrastructure**.

The `terraform plan` output becomes your safety net. It tells you exactly what will happen before anything happens.

---

## Exercise 1 -- Apply the Starting Configuration

1. Review `main.tf` in this directory. It creates an S3 bucket with two tags.
2. Initialize and apply:

```bash
terraform init
terraform apply
```

3. Confirm the apply. Terraform creates the bucket.
4. Verify the bucket exists:

```bash
aws s3 ls | grep shopsmart
```

---

## Exercise 2 -- Update in Place (Add a Tag)

Some changes do not require destroying the resource. Adding a tag is one of them.

1. Open `main.tf` and add a new tag inside the `tags` block:

```hcl
    ManagedBy = "terraform"
```

2. Run the plan:

```bash
terraform plan
```

3. Study the output. You should see the `~` symbol, which means **update in place**:

```
  ~ resource "aws_s3_bucket" "shopsmart_uploads" {
      ~ tags = {
          + "ManagedBy" = "terraform"
        }
    }
```

The `~` means Terraform will modify the existing resource without destroying it. The `+` next to the tag means a new key-value pair is being added.

4. Apply the change:

```bash
terraform apply
```

---

## Exercise 3 -- Destroy and Recreate (Change the Bucket Name)

Changing the bucket name is a different story. S3 bucket names are immutable in AWS -- you cannot rename a bucket. Terraform must destroy the old bucket and create a new one.

1. In `main.tf`, change the `bucket` argument to a new name:

```hcl
    bucket = "shopsmart-uploads-v2-${random_id.suffix.hex}"
```

   Since we are using `random_id` for uniqueness, change the resource name or the prefix to trigger the recreate. The simplest approach: change the bucket prefix directly in the `bucket` argument.

   For this exercise, simply change the bucket line to:

```hcl
    bucket = "shopsmart-archive-${random_id.suffix.hex}"
```

2. Run the plan:

```bash
terraform plan
```

3. Study the output carefully. You should see the `-/+` symbols, which mean **destroy then create**:

```
-/+ resource "aws_s3_bucket" "shopsmart_uploads" {
      ~ bucket = "shopsmart-uploads-xxxx" -> "shopsmart-archive-xxxx" # forces replacement
    }
```

The `-/+` tells you: "I am going to delete this resource and create a new one." Everything in the old bucket would be lost.

4. **DO NOT apply yet.** This is the "look before you leap" lesson. Read the plan. Understand the consequences. In production, this plan output is where you catch mistakes before they become outages.

---

## Exercise 4 -- Apply the Destructive Change

Now that you understand what will happen, go ahead and apply.

1. Apply:

```bash
terraform apply
```

2. Observe the output. Terraform destroys the old bucket first, then creates the new one.
3. Verify:

```bash
aws s3 ls | grep shopsmart
```

The old bucket name is gone. The new one exists.

---

## Exercise 5 -- Break It: force_destroy

What happens if the bucket has objects in it and you try to destroy it?

1. Upload a test file to the bucket:

```bash
echo "test data" > /tmp/test.txt
aws s3 cp /tmp/test.txt s3://$(terraform output -raw bucket_name)/test.txt
```

2. Now try to destroy:

```bash
terraform destroy
```

3. Terraform will fail with an error like:

```
Error: deleting S3 Bucket (shopsmart-archive-xxxx): BucketNotEmpty:
The bucket you tried to delete is not empty
```

AWS refuses to delete a bucket that contains objects. Terraform cannot force it unless you tell it to.

4. Add `force_destroy = true` to the bucket resource in `main.tf`:

```hcl
resource "aws_s3_bucket" "shopsmart_uploads" {
    bucket        = "shopsmart-archive-${random_id.suffix.hex}"
    force_destroy = true
    ...
}
```

5. Apply the change (this is an in-place update):

```bash
terraform apply
```

6. Now destroy will work:

```bash
terraform destroy
```

`force_destroy` tells Terraform to empty the bucket before deleting it. Use this in lab and dev environments. In production, think twice -- it deletes all objects permanently.

---

## Exercise 6 -- Tear Down Everything

If you have not already destroyed in Exercise 5, clean up now.

1. Run destroy:

```bash
terraform destroy
```

2. Terraform shows you a plan of what it will delete. **Read it before typing yes.** This is the same plan mechanism that protects you during apply.

3. Confirm the destroy. Verify everything is gone:

```bash
aws s3 ls | grep shopsmart
terraform show
```

---

## Key Takeaway

**Plan is your seatbelt. Always read it before apply.**

The plan output uses clear symbols to tell you what will happen:

| Symbol | Meaning |
|--------|---------|
| `+`    | Create a new resource |
| `-`    | Destroy a resource |
| `~`    | Update a resource in place |
| `-/+`  | Destroy and recreate a resource |

Before every `terraform apply`, run `terraform plan` and read the output. Understand what is changing and why. In production, this habit prevents outages.
