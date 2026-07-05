variable "aws_region" {
  description = "AWS region, passed by Terragrunt."
  type        = string
}

variable "environment" {
  description = "Environment name, for example dev, staging, or prod."
  type        = string
}

variable "name_prefix" {
  description = "Name prefix for all network resources."
  type        = string
}

variable "common_tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC."
  type        = string
}

variable "availability_zones" {
  description = "Optional AZ override. Uses the first two available AZs when empty."
  type        = list(string)
  default     = []
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDRs. Defaults to two /24s derived from vpc_cidr when empty."
  type        = list(string)
  default     = []
}

variable "allowed_ingress_cidrs" {
  description = "CIDRs allowed into the controlled-ingress security group. Empty means no ingress."
  type        = list(string)
  default     = []
}

variable "allowed_ingress_ports" {
  description = "TCP ports allowed into the controlled-ingress security group. Empty means no ingress."
  type        = list(number)
  default     = []
}

variable "create_internet_gateway" {
  description = "Create an Internet Gateway and public route table. Free by itself, but traffic can still cost money."
  type        = bool
  default     = true
}

variable "create_gateway_endpoints" {
  description = "Create S3 and DynamoDB gateway VPC endpoints. Disabled by default."
  type        = bool
  default     = false
}
