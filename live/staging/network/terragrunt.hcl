include "root" {
  path = find_in_parent_folders()
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("_env.hcl"))
}

dependency "organization" {
  config_path = "../../global/organization"
}

# This stack runs Terraform in the environment account by generating a provider
# that assumes the Organization-created role. Using top-level `iam_role` cannot
# reference dependency outputs because Terragrunt evaluates it too early.
generate "env_provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  assume_role {
    role_arn     = "${dependency.organization.outputs.environment_account_role_arns[local.env.locals.environment]}"
    session_name = "terragrunt-${local.env.locals.environment}-network"
  }

  default_tags {
    tags = var.common_tags
  }
}
EOF
}

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
