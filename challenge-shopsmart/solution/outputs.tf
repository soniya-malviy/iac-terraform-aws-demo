# =============================================================================
# Outputs
# =============================================================================

output "vpc_id" {
  description = "The ID of the ShopSmart VPC"
  value       = aws_vpc.main.id
}

output "ec2_public_ip" {
  description = "The public IP address of the web server"
  value       = aws_instance.web.public_ip
}

output "s3_product_images_bucket" {
  description = "Name of the S3 bucket for product images"
  value       = aws_s3_bucket.product_images.bucket
}

output "s3_app_logs_bucket" {
  description = "Name of the S3 bucket for application logs"
  value       = aws_s3_bucket.app_logs.bucket
}
