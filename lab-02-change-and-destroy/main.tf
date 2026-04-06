# -------------------------------------------------------
# Lab 02 - Change and Destroy
# -------------------------------------------------------
# This configuration creates an S3 bucket with tags.
# You will modify this file throughout the lab exercises
# to observe how Terraform handles different kinds of
# changes: update-in-place vs destroy-and-recreate.
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
# S3 Bucket - ShopSmart Uploads
# ----------------------------------------------------
# This bucket stores uploaded files for the ShopSmart
# application. We tag it so we know which environment
# and team owns it.
# ----------------------------------------------------
resource "aws_s3_bucket" "shopsmart_uploads" {
  bucket = "shopsmart-uploads-${random_id.suffix.hex}"

  tags = {
    Environment = "lab"
    Team        = "platform"
  }
}

# Output the bucket name so we can reference it easily.
output "bucket_name" {
  value = aws_s3_bucket.shopsmart_uploads.bucket
}
