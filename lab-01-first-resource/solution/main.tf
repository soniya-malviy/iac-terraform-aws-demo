# ---------------------------------------------------------------
# Lab 01 - Solution
# ---------------------------------------------------------------
# This is the completed main.tf for Lab 01.
# Replace <YOURNAME> in the bucket name with something unique
# (e.g., your first name, GitHub handle, or initials + date).
# S3 bucket names must be globally unique across all of AWS.
# ---------------------------------------------------------------

terraform {
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

resource "aws_s3_bucket" "shopsmart_logs" {
  bucket = "shopsmart-logs-<YOURNAME>"   # <-- Replace <YOURNAME> with something unique!
}
