output "bucket_arn" {
  description = "ARN of the S3 data bucket"
  value       = aws_s3_bucket.data.arn
}

output "bucket_name" {
  description = "Name of the S3 data bucket"
  value       = aws_s3_bucket.data.bucket
}

output "bucket_region" {
  description = "Region of the S3 data bucket"
  value       = aws_s3_bucket.data.region
}
