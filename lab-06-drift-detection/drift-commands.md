# Drift Commands Reference

AWS CLI commands to simulate and detect configuration drift without using the AWS Console.

---

## Step 1 -- Get Your Resource Identifiers

After running `terraform apply`, grab the output values:

```bash
terraform output bucket_name
terraform output security_group_id
```

Store them in shell variables for convenience:

```bash
BUCKET_NAME=$(terraform output -raw bucket_name)
SG_ID=$(terraform output -raw security_group_id)
```

---

## Step 2 -- Create Drift

### Add a manual tag to the S3 bucket

The `put-bucket-tagging` command replaces all tags, so you must include the originals plus the new one:

```bash
aws s3api put-bucket-tagging \
  --bucket "$BUCKET_NAME" \
  --tagging 'TagSet=[{Key=Environment,Value=production},{Key=Team,Value=platform},{Key=ManagedBy,Value=terraform},{Key=Project,Value=drift-lab},{Key=ManuallyAdded,Value=true}]'
```

### Add an overly permissive security group rule

This adds a rule allowing ALL traffic from anywhere -- the classic 2 AM mistake:

```bash
aws ec2 authorize-security-group-ingress \
  --group-id "$SG_ID" \
  --protocol -1 \
  --cidr 0.0.0.0/0
```

---

## Step 3 -- Verify the Drift Exists

### Check the S3 bucket tags

```bash
aws s3api get-bucket-tagging --bucket "$BUCKET_NAME"
```

You should see the extra `ManuallyAdded` tag in the output.

### Check the security group rules

```bash
aws ec2 describe-security-groups \
  --group-ids "$SG_ID" \
  --query 'SecurityGroups[0].IpPermissions' \
  --output table
```

You should see two inbound rules: the original SSH rule and the new "all traffic" rule.

---

## Step 4 -- Detect Drift with Terraform

```bash
terraform plan
```

Terraform will show that it wants to:

- Remove the `ManuallyAdded` tag from the S3 bucket
- Remove the "all traffic" inbound rule from the security group

---

## Step 5 -- Fix the Drift

### Option A -- Revert to code (most common)

```bash
terraform apply
```

This removes the manual changes. Infrastructure matches code again.

### Option B -- Update state only (acknowledge the changes)

```bash
terraform apply -refresh-only
```

This updates the state file to match reality but does not change infrastructure. Use this only if you plan to update the code next.

---

## Step 6 -- Confirm No Drift

```bash
terraform plan
```

Expected output:

```
No changes. Your infrastructure matches the configuration.
```
