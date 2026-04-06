# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Variables for the ShopSmart infrastructure stack
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

variable "project_name" {
  description = "Project name used for resource naming and tags"
  type        = string
  default     = "shopsmart"
}

variable "environment" {
  description = "Environment name (e.g., lab, dev, staging, prod)"
  type        = string
  default     = "lab"
}
