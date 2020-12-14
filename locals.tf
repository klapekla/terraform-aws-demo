locals {
  az = data.aws_availability_zones.available.names
  az_count = length(local.az)
}