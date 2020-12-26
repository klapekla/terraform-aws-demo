output "bastion_key_name" {
  value = aws_key_pair.my_bastion_key.key_name
}

# output "internal_key_name" {
#   value = aws_key_pair.my_internal_key.key_name
# }