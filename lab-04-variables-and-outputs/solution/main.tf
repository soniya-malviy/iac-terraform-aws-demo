# Lab 04 - Variables and Outputs (Solution)
# Parameterized config -- no hardcoded values!

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.region
}

resource "aws_s3_bucket" "data" {
  bucket = "${var.project_name}-${var.environment}-data"

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}
