# ---------------------------------------------------------------
# Lab 01 - Your First Terraform Resource
# ---------------------------------------------------------------
# Fill in every blank marked with "______" to complete this file.
# Then run: terraform init -> terraform plan -> terraform apply
# ---------------------------------------------------------------

# ---------------------------
# 1. Terraform Settings Block
# ---------------------------
# This block tells Terraform which provider plugins it needs.
# We need the AWS provider so Terraform can talk to AWS APIs.
#
# The "source" tells Terraform where to download the provider.
# AWS lives at "hashicorp/aws" in the Terraform Registry.

terraform {
  required_providers {
    aws = {
      source  = "______"       # <-- Fill in the provider source (hint: hashicorp/???)
      version = "~> 5.0"       # Use any 5.x version
    }
  }
}

# ---------------------------
# 2. Provider Configuration
# ---------------------------
# The provider block configures the plugin we declared above.
# At minimum, AWS needs to know which REGION to target.
#
# Common regions: us-east-1, us-west-2, eu-west-1

provider "aws" {
  region = "______"            # <-- Fill in an AWS region (hint: us-east-1)
}

# ---------------------------
# 3. Resource Block
# ---------------------------
# A resource block declares a piece of infrastructure.
#
# Syntax:
#   resource "<PROVIDER>_<TYPE>" "<LOCAL_NAME>" {
#     argument = "value"
#   }
#
# We are creating an S3 bucket to store ShopSmart application logs.
# The bucket name must be globally unique across ALL of AWS.
# Replace <YOURNAME> with your actual name or handle.

resource "aws_s3_bucket" "shopsmart_logs" {
  bucket = "______"            # <-- Fill in a unique bucket name (hint: shopsmart-logs-<YOURNAME>)
}
