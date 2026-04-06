variable "environment" {
  description = "Deployment environment (dev/staging/prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name used in resource naming"
  type        = string
  default     = "shopsmart"
}

variable "region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-east-1"
}
