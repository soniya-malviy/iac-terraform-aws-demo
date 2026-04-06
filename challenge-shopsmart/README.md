# Disaster Recovery Challenge: Rebuild ShopSmart

## The Scenario

It happened. AWS `us-east-1` is down. The CEO is on the phone. You need to rebuild
ShopSmart's infrastructure in `us-west-2`. You have the architecture document below
and your Terraform skills. Go.

**Time Limit:** 45 minutes (suggested)

---

## Rules

1. You must write **ALL** Terraform from scratch. No copying from previous labs (honor system).
2. You **CAN** reference the [Terraform documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs).
3. You must use variables for reusable values --- no hardcoding CIDRs, AMI IDs, or project names directly in resources.
4. All resources must include the required tags (see below).

---

## Architecture Spec

Read the full architecture document in [`architecture.md`](./architecture.md). Here is the summary of what you must build:

### Networking

| Resource | Details |
|---|---|
| VPC | CIDR `10.0.0.0/16` |
| Public Subnet 1 | CIDR `10.0.1.0/24`, first AZ in region |
| Public Subnet 2 | CIDR `10.0.2.0/24`, second AZ in region |
| Internet Gateway | Attached to the VPC |
| Route Table | Default route (`0.0.0.0/0`) pointing to the IGW, associated with both public subnets |

### Compute

| Resource | Details |
|---|---|
| EC2 Instance | `t2.micro`, Amazon Linux 2, placed in **Public Subnet 1** |
| Security Group | Allow **HTTP (80)** from `0.0.0.0/0`, allow **SSH (22)** from `10.0.0.0/8` only |

### Storage

| Resource | Details |
|---|---|
| S3 Bucket (Product Images) | Bucket for storing product images |
| S3 Bucket (Application Logs) | Bucket for application logs with a **lifecycle rule** that transitions objects to Glacier after **90 days** |

### Tags (Required on ALL Resources)

```hcl
Project     = "shopsmart"
Environment = "disaster-recovery"
ManagedBy   = "terraform"
```

---

## Grading Rubric (Self-Check)

When you are finished, verify the following:

- [ ] `terraform validate` passes
- [ ] `terraform plan` shows all expected resources
- [ ] All resources are properly tagged
- [ ] S3 log bucket has a lifecycle rule (transition to Glacier after 90 days)
- [ ] EC2 instance is in the correct subnet (Public Subnet 1)
- [ ] Security group rules are restrictive (SSH is **not** open to `0.0.0.0/0`)
- [ ] Variables are used for reusable values (no hardcoding)
- [ ] Outputs show: VPC ID, EC2 public IP, S3 bucket names

---

## Hints

Try to complete the challenge without hints first. If you get stuck, reveal them one at a time.

<details>
<summary>Hint 1</summary>

Start with the VPC. Everything depends on it.

</details>

<details>
<summary>Hint 2</summary>

Use `terraform graph` to check your dependency tree makes sense.

</details>

<details>
<summary>Hint 3</summary>

Don't forget the route table association --- a subnet without a route to the IGW has no internet access.

</details>

---

## Solution

A reference solution is available in the [`solution/`](./solution/) directory.
**Do not look at it until you have completed the challenge or exhausted your time.**

Good luck. The CEO is waiting.
