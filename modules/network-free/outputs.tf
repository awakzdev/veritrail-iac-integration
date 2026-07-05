output "vpc_id" {
  description = "VPC ID."
  value       = aws_vpc.this.id
}

output "vpc_cidr" {
  description = "VPC CIDR block."
  value       = aws_vpc.this.cidr_block
}

output "public_subnet_ids" {
  description = "Public subnet IDs."
  value       = values(aws_subnet.public)[*].id
}

output "default_security_group_id" {
  description = "Locked-down default security group ID."
  value       = aws_default_security_group.locked_down.id
}

output "no_ingress_security_group_id" {
  description = "No-ingress security group ID."
  value       = aws_security_group.no_ingress.id
}

output "controlled_ingress_security_group_id" {
  description = "Controlled-ingress security group ID."
  value       = aws_security_group.controlled_ingress.id
}

output "s3_gateway_endpoint_id" {
  description = "Optional S3 gateway endpoint ID."
  value       = try(aws_vpc_endpoint.s3_gateway[0].id, null)
}

output "dynamodb_gateway_endpoint_id" {
  description = "Optional DynamoDB gateway endpoint ID."
  value       = try(aws_vpc_endpoint.dynamodb_gateway[0].id, null)
}
