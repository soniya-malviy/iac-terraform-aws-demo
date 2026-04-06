# Anatomy of a Terraform State File

Terraform state is stored as JSON. Below is a simplified example of what `terraform.tfstate` looks like after applying the Lab 03 configuration, with annotations explaining each key section.

---

## Full Example (Simplified)

```json
{
  "version": 4,
  "terraform_version": "1.7.0",
  "serial": 3,
  "lineage": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "outputs": {},
  "resources": [
    {
      "mode": "managed",
      "type": "aws_s3_bucket",
      "name": "data_store",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "lab03-data-store-20260401120000",
            "arn": "arn:aws:s3:::lab03-data-store-20260401120000",
            "bucket": "lab03-data-store-20260401120000",
            "bucket_prefix": "lab03-data-store-",
            "region": "us-east-1",
            "tags": {
              "Name": "Lab 03 Data Store",
              "Environment": "learning",
              "Lab": "03-state"
            },
            "versioning": [
              {
                "enabled": false
              }
            ]
          }
        }
      ]
    },
    {
      "mode": "managed",
      "type": "aws_s3_bucket",
      "name": "logs",
      "provider": "provider[\"registry.terraform.io/hashicorp/aws\"]",
      "instances": [
        {
          "schema_version": 0,
          "attributes": {
            "id": "lab03-logs-20260401120000",
            "arn": "arn:aws:s3:::lab03-logs-20260401120000",
            "bucket": "lab03-logs-20260401120000",
            "bucket_prefix": "lab03-logs-",
            "region": "us-east-1",
            "tags": {
              "Name": "Lab 03 Logs",
              "Environment": "learning",
              "Lab": "03-state"
            }
          }
        }
      ]
    }
  ]
}
```

---

## Field-by-Field Annotations

### Top-Level Fields

| Field | Description |
|---|---|
| `version` | The state file format version. Currently `4`. Terraform uses this to handle upgrades between state format versions. |
| `terraform_version` | The version of Terraform that last wrote this state file. Useful for debugging compatibility issues. |
| `serial` | An integer that increments every time the state is written. Terraform uses this to detect concurrent modifications and prevent conflicts. |
| `lineage` | A unique UUID generated when the state is first created. It identifies this specific state "lineage" -- if two state files have different lineages, Terraform refuses to use one as a replacement for the other. This prevents accidentally overwriting unrelated state. |
| `outputs` | A map of any `output` values defined in your configuration. Empty here because Lab 03 defines no outputs. |
| `resources` | The heart of the state file -- an array of every resource Terraform manages. |

### Inside Each Resource

| Field | Description |
|---|---|
| `mode` | Either `"managed"` (a `resource` block) or `"data"` (a `data` block). |
| `type` | The resource type, e.g., `aws_s3_bucket`. Maps to the provider's resource schema. |
| `name` | The local name you gave the resource in your `.tf` file (e.g., `data_store`). Combined with `type`, this forms the resource address: `aws_s3_bucket.data_store`. |
| `provider` | The fully qualified provider path. Tells Terraform which provider plugin manages this resource. |
| `instances` | An array of resource instances. For simple resources, there is one instance. If you use `count` or `for_each`, there will be multiple instances (one per index or key). |

### Inside Each Instance

| Field | Description |
|---|---|
| `schema_version` | The version of the resource schema used by the provider. Providers can migrate instance data between schema versions. |
| `attributes` | Every attribute of the real-world resource, as last known by Terraform. This is how Terraform detects drift -- it compares these stored attributes against what the cloud provider returns on refresh. |
| `attributes.id` | The unique identifier for this resource in AWS. For S3 buckets, this is the bucket name. |
| `attributes.arn` | The Amazon Resource Name -- a globally unique identifier within AWS. |
| `attributes.tags` | The tags applied to the resource, matching what you defined in `main.tf`. |

---

## Why This Matters

- **Terraform reads state before every plan.** It compares state (what it thinks exists) against your config (what you want) and the cloud (what actually exists) to build the execution plan.
- **If state is missing,** Terraform has no record of existing resources and will try to create everything from scratch.
- **If state is wrong,** Terraform might try to modify or destroy the wrong resources.
- **Sensitive values** (passwords, keys, tokens) appear in plain text in the attributes. This is why state files must be stored securely and never committed to Git.
