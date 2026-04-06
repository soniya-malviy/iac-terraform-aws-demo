# -------------------------------------------------------
# Lab 02 - Change and Destroy (Solution)
# -------------------------------------------------------
# Final state after all exercises:
#   - Bucket name changed to "shopsmart-archive-*"
#   - Extra tag "ManagedBy" added
#   - force_destroy enabled so the bucket can be deleted
#     even when it contains objects
# -------------------------------------------------------

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Random suffix to make the bucket name globally unique.
resource "random_id" "suffix" {
  byte_length = 4
}

# ----------------------------------------------------
# S3 Bucket - ShopSmart Archive (renamed from Uploads)
# ----------------------------------------------------
# Changing the bucket name from "shopsmart-uploads-*" to
# "shopsmart-archive-*" forces Terraform to destroy the
# old bucket and create a new one (destroy-and-recreate).
#
# force_destroy = true allows Terraform to delete the
# bucket even if it still contains objects. Without this,
# AWS returns a BucketNotEmpty error and the destroy fails.
# ----------------------------------------------------
resource "aws_s3_bucket" "shopsmart_uploads" {
  bucket        = "shopsmart-archive-${random_id.suffix.hex}"
  force_destroy = true

  tags = {
    Environment = "lab"
    Team        = "platform"
    ManagedBy   = "terraform"
  }
}

# Output the bucket name so we can reference it easily.
output "bucket_name" {
  value = aws_s3_bucket.shopsmart_uploads.bucket
}
