include "root" {
  path = find_in_parent_folders()
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("_env.hcl"))
}

terraform {
  source = "../../../modules/iam-baseline"
}

inputs = {
  environment                    = local.env.locals.environment
  name_prefix                    = local.env.locals.name_prefix
  create_account_password_policy = false
  create_account_alias           = local.env.locals.create_account_alias
  account_alias                  = local.env.locals.account_alias
  trusted_aws_principal_arns     = []
  attach_cost_guardrail_to_roles = true
  common_tags                    = merge({ ManagedBy = "Terraform/Terragrunt", Project = "aws-free-baseline" }, local.env.locals.environment_tags, { Component = "iam" })
}
