# Lab 04 - Variables and Outputs
# Starting config with HARDCODED values
# ----------------------------------------
# TODO: These hardcoded values should be variables!
# Imagine needing this same setup for dev, staging, and prod.
# You would have to copy this file and change every string by hand.

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# TODO: The region is hardcoded -- make it a variable
provider "aws" {
  region = var.aws_region
}

# TODO: The bucket name is hardcoded -- make it use variables
resource "aws_s3_bucket" "data" {
  bucket = var.bucket_name

  # TODO: These tags are hardcoded -- make them use variables
  tags = {
    Environment = var.environment
    Project     = var.project
    ManagedBy   = var.managed_by
  }
}
