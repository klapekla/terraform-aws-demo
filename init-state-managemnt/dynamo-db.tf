resource "aws_dynamodb_table" "my_dynamodb_for_state_management" {
  name           = var.dynamodb
  hash_key       = "LockID"
  write_capacity = 1
  read_capacity  = 1


  attribute {
    name = "LockID"
    type = "S"
  }

  tags = {
    Name        = "my_dynamodb_for_state_management"
    Project     = var.project_tag
  }
}