include "root" {
  path = find_in_parent_folders()
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("_env.hcl"))
}

terraform {
  source = "../../../modules/organization-baseline"
}

inputs = {
  organization_name             = local.env.locals.organization_name
  workloads_ou_name             = local.env.locals.workloads_ou_name
  organization_access_role_name = local.env.locals.organization_access_role_name
  environment_accounts          = local.env.locals.environment_accounts
  create_cost_guardrail_scp     = local.env.locals.create_cost_guardrail_scp
  cost_guardrail_scp_name       = local.env.locals.cost_guardrail_scp_name
  common_tags                   = merge({ ManagedBy = "Terraform/Terragrunt", Project = "veritrail-aws-baseline" }, local.env.locals.global_tags, { Component = "organization" })
}
