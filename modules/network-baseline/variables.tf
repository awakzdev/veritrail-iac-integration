variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "name_prefix" {
  description = "Fallback name prefix for all network resources when resource_names does not override them."
  type        = string
}

variable "resource_names" {
  description = "Exact resource names, usually provided from Terragrunt. Missing keys fall back to generated names."
  type        = map(string)
  default     = {}
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
  description = "Create an Internet Gateway and public route table. No direct hourly charge by itself, but traffic can still cost money."
  type        = bool
  default     = true
}

variable "create_gateway_endpoints" {
  description = "Create S3 and DynamoDB gateway VPC endpoints. Disabled by default."
  type        = bool
  default     = false
}
