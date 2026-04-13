variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "environment" {
  description = "Environment name (dev/staging/prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "managed_by" {
  description = "Who manages the resource"
  type        = string
  default     = "terraform"
}