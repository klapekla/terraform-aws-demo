resource "aws_key_pair" "my_bastion_key" {
  key_name   = "my_bastion_key"
  public_key = file(var.external_public_key_location)
}

# resource "aws_key_pair" "my_internal_key" {
#   key_name   = "my_internal_key"
#   public_key = file(var.internal_public_key_location)
# }