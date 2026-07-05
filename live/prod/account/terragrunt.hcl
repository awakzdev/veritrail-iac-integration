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
# running Terraform, so this IAM baseline is created inside the environment account.
iam_role = dependency.organization.outputs.environment_account_role_arns[local.env.locals.environment]

terraform {
  source = "../../../modules/iam-baseline"
}

inputs = {
  environment                    = local.env.locals.environment
  name_prefix                    = local.env.locals.name_prefix
  resource_names                 = local.env.locals.resource_names
  create_account_password_policy = true
  create_account_alias           = false
  account_alias                  = null
  trusted_aws_principal_arns     = []
  attach_cost_guardrail_to_roles = true
  common_tags                    = merge({ ManagedBy = "Terraform/Terragrunt", Project = "veritrail-aws-baseline" }, local.env.locals.environment_tags, { Component = "iam" })
}
