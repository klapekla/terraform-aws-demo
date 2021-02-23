output "region" {
  value = var.region
}

output "s3_bucket" {
  value = aws_s3_bucket.my_s3_bucket_for_state_management.bucket
}

output "dynamodb" {
  value = aws_dynamodb_table.my_dynamodb_for_state_management.name
}