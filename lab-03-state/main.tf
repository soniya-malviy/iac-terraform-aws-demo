# Lab 03 - Terraform State
# This configuration creates two S3 buckets so we can explore
# how Terraform tracks resources in its state file.

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

# --- S3 Bucket: Data Store ---
# A bucket to hold application data.
# After applying, find this resource in terraform.tfstate and inspect its attributes.

resource "aws_s3_bucket" "data_store" {
  bucket_prefix = "lab03-data-store-"

  tags = {
    Name        = "Lab 03 Data Store"
    Environment = "learning"
    Lab         = "03-state"
  }
}

# --- S3 Bucket: Logs ---
# A second bucket so that `terraform state list` shows multiple resources.

resource "aws_s3_bucket" "logs" {
  bucket_prefix = "lab03-logs-"

  tags = {
    Name        = "Lab 03 Logs"
    Environment = "learning"
    Lab         = "03-state"
  }
}
