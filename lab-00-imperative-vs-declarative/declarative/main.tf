# =============================================================================
# DECLARATIVE S3 Bucket Configuration
#
# We declare WHAT we want, not HOW to create it.
#
# Terraform reads this file, compares the desired state to the actual state
# of your AWS account (tracked in terraform.tfstate), and makes only the
# changes necessary to bring reality in line with this configuration.
#
# Run it once  -> bucket is created.
# Run it again -> "No changes." That is idempotency.
# =============================================================================

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# ---------------------------------------------------------------------------
# This is the entire infrastructure definition.
# We say "I want an S3 bucket with this name" and Terraform handles the rest.
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "shopsmart_images" {
  bucket = var.bucket_name
}
