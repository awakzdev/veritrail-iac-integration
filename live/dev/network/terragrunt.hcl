include "root" {
  path = find_in_parent_folders()
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("_env.hcl"))
}

dependency "organization" {
  config_path = "../../global/organization"
}

# Terragrunt assumes the Organization-created role in the member account before
# running Terraform, so this network baseline is created inside the environment account.
iam_role = dependency.organization.outputs.environment_account_role_arns[local.env.locals.environment]

terraform {
  source = "../../../modules/network-baseline"
}

inputs = {
  environment              = local.env.locals.environment
  name_prefix              = local.env.locals.name_prefix
  resource_names           = local.env.locals.resource_names
  vpc_cidr                 = local.env.locals.vpc_cidr
  public_subnet_cidrs      = local.env.locals.public_subnet_cidrs
  allowed_ingress_cidrs    = local.env.locals.allowed_ingress_cidrs
  allowed_ingress_ports    = local.env.locals.allowed_ingress_ports
  create_gateway_endpoints = false
  common_tags              = merge({ ManagedBy = "Terraform/Terragrunt", Project = "veritrail-aws-baseline" }, local.env.locals.environment_tags, { Component = "network" })
}
