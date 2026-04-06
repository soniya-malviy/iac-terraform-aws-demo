# =============================================================================
# Lab 06 - Drift Detection
# =============================================================================
# This configuration defines the DESIRED STATE of our infrastructure.
# Any manual changes made outside of Terraform will be detected as drift
# and can be reverted with `terraform apply`.
# =============================================================================

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

# -----------------------------------------------------------------------------
# Data source: Default VPC
# We use the default VPC so we don't need to create networking from scratch.
# -----------------------------------------------------------------------------

data "aws_vpc" "default" {
  default = true
}

# -----------------------------------------------------------------------------
# S3 Bucket
# These tags represent the desired state. If someone manually adds, removes,
# or changes a tag in the console, `terraform plan` will detect the drift.
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = {
    Environment = "production"
    Team        = "platform"
    ManagedBy   = "terraform"
    Project     = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Security Group
# This group allows ONLY SSH from the internal network (10.0.0.0/8).
# If someone manually adds a rule allowing 0.0.0.0/0, that is drift --
# and Terraform will want to remove it on the next apply.
# -----------------------------------------------------------------------------

resource "aws_security_group" "this" {
  name        = "${var.project_name}-sg"
  description = "Managed by Terraform - only SSH from internal network"
  vpc_id      = data.aws_vpc.default.id

  # Inbound: SSH from internal network only
  ingress {
    description = "SSH from internal network"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  # Outbound: allow all
  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "${var.project_name}-sg"
    ManagedBy = "terraform"
    Project   = var.project_name
  }
}

# -----------------------------------------------------------------------------
# Outputs
# These make it easy to copy resource identifiers for the drift exercises.
# -----------------------------------------------------------------------------

output "bucket_name" {
  description = "Name of the S3 bucket (use this in the drift commands)"
  value       = aws_s3_bucket.this.bucket
}

output "security_group_id" {
  description = "ID of the security group (use this in the drift commands)"
  value       = aws_security_group.this.id
}
