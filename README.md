# Infrastructure as Code with Terraform — Lab Course

> **Scenario:** You are the platform team at **ShopSmart**, an e-commerce company.
> Yesterday, AWS `us-east-1` went down. Your CEO asks: *"How fast can we rebuild everything?"*
> Your honest answer: *"Weeks... we'd have to remember every checkbox we clicked."*
>
> By the end of these labs, your answer will be: **`terraform apply` — 12 minutes.**

---

## How This Course Works

Each lab introduces **one concept** through hands-on exercises. Labs build on each other but each folder is self-contained — you can `terraform init` in any lab independently.

The course follows a **"break it to understand it"** philosophy. You will intentionally cause failures, observe what happens, and then fix things. This is how infrastructure engineers actually learn.

### Lab Progression

| Lab | Concept | What You'll Do |
|-----|---------|---------------|
| [00](lab-00-imperative-vs-declarative/) | Imperative vs Declarative | Run a bash script and a Terraform config side-by-side, then see why one breaks on re-run |
| [01](lab-01-first-resource/) | Your First Resource | Write an S3 bucket from scratch, learn `init`, `plan`, `apply` |
| [02](lab-02-change-and-destroy/) | Change & Destroy | Modify resources and watch Terraform's replace-vs-update logic |
| [03](lab-03-state/) | State | Inspect the state file, understand why it matters, break it on purpose |
| [04](lab-04-variables-and-outputs/) | Variables & Outputs | Parameterize your config, extract useful info after apply |
| [05](lab-05-dependencies/) | Dependencies & Graphs | Build a multi-resource stack, visualize the dependency graph |
| [06](lab-06-drift-detection/) | Drift Detection | Play the "cowboy admin," manually change infra, then see Terraform catch you |
| [Challenge](challenge-shopsmart/) | **Capstone** | Rebuild ShopSmart's full infrastructure from a written spec — the disaster recovery test |

---

## Prerequisites

### Required Software

```bash
# Terraform (v1.5+)
brew install terraform    # macOS
# or: https://developer.hashicorp.com/terraform/downloads

# AWS CLI (v2)
brew install awscli

# Graphviz (for Lab 05 only)
brew install graphviz
```

### AWS Setup

You need an AWS account with programmatic access. We recommend using a **sandbox/dev account** — these labs create real (but cheap) resources.

```bash
# Configure credentials
aws configure
# Use region: us-east-1
```

> **Cost Warning:** All labs use free-tier-eligible resources (S3, small EC2, etc.).
> Always run `terraform destroy` when you finish a lab to avoid charges.

### Verify Your Setup

```bash
terraform version   # Should show v1.5+
aws sts get-caller-identity   # Should show your account
```
