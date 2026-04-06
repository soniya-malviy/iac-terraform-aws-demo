output "bucket_arn" {
  description = "The ARN of the S3 bucket created by Terraform."
  value       = aws_s3_bucket.shopsmart_images.arn
}

output "bucket_name" {
  description = "The name of the S3 bucket created by Terraform."
  value       = aws_s3_bucket.shopsmart_images.bucket
}
