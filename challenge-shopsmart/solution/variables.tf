# =============================================================================
# Variables
# =============================================================================

variable "project" {
  description = "Project name used for resource naming and tagging"
  type        = string
  default     = "shopsmart"
}

variable "environment" {
  description = "Environment name used for tagging"
  type        = string
  default     = "disaster-recovery"
}

variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-west-2"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_1_cidr" {
  description = "CIDR block for public subnet 1"
  type        = string
  default     = "10.0.1.0/24"
}

variable "public_subnet_2_cidr" {
  description = "CIDR block for public subnet 2"
  type        = string
  default     = "10.0.2.0/24"
}

variable "instance_type" {
  description = "EC2 instance type for the web server"
  type        = string
  default     = "t2.micro"
}

variable "ssh_allowed_cidr" {
  description = "CIDR block allowed to SSH into the web server (must not be 0.0.0.0/0)"
  type        = string
  default     = "10.0.0.0/8"
}
