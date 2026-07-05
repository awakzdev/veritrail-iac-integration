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
  environment                    = "management"
  name_prefix                    = local.env.locals.name_prefix
  resource_names                 = {
    readonly_role         = "${local.env.locals.name_prefix}-management-readonly"
    security_audit_role   = "${local.env.locals.name_prefix}-management-security-audit"
    cost_guardrail_policy = "${local.env.locals.name_prefix}-management-cost-guardrail"
  }
  create_account_password_policy = true
  create_account_alias           = local.env.locals.create_account_alias
  account_alias                  = local.env.locals.account_alias
  trusted_aws_principal_arns     = []
  attach_cost_guardrail_to_roles = true
  common_tags                    = merge({ ManagedBy = "Terraform/Terragrunt", Project = "veritrail-aws-baseline" }, local.env.locals.global_tags, { Component = "iam-management" })
}
