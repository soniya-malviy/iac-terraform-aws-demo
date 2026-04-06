variable "bucket_name" {
  description = "Name of the S3 bucket. Must be globally unique."
  type        = string
  default     = "drift-lab-demo-bucket"
}

variable "project_name" {
  description = "Project name used for naming and tagging resources."
  type        = string
  default     = "drift-lab"
}
