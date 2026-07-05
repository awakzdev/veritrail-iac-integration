include "root" {
  path = find_in_parent_folders()
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("_env.hcl"))
}

terraform {
  source = "../../../modules/network-free"
}

inputs = {
  environment           = local.env.locals.environment
  name_prefix           = local.env.locals.name_prefix
  vpc_cidr              = local.env.locals.vpc_cidr
  public_subnet_cidrs   = local.env.locals.public_subnet_cidrs
  allowed_ingress_cidrs = local.env.locals.allowed_ingress_cidrs
  allowed_ingress_ports = local.env.locals.allowed_ingress_ports
  create_gateway_endpoints = false
  common_tags              = merge({ ManagedBy = "Terraform/Terragrunt", Project = "aws-free-baseline" }, local.env.locals.environment_tags, { Component = "network" })
}
