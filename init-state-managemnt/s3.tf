resource "aws_s3_bucket" "my_s3_bucket_for_state_management" {
  bucket = var.s3_bucket
  acl    = "private"

  tags = {
    Name        = "my_s3_bucket_for_state_management"
    Project     = var.project_tag
  }
}