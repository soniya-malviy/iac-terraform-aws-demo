# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Outputs for the ShopSmart infrastructure stack
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

output "vpc_id" {
  description = "The ID of the ShopSmart VPC"
  value       = aws_vpc.main.id
}

output "subnet_id" {
  description = "The ID of the public subnet"
  value       = aws_subnet.public.id
}

output "instance_public_ip" {
  description = "The public IP address of the ShopSmart web server"
  value       = aws_instance.web.public_ip
}

output "s3_bucket_name" {
  description = "The name of the S3 bucket for application data"
  value       = aws_s3_bucket.app_data.bucket
}
