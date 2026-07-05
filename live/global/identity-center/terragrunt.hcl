include "root" {
  path = find_in_parent_folders()
}

locals {
  env = read_terragrunt_config(find_in_parent_folders("_env.hcl"))
}

dependency "organization" {
  config_path = "../organization"

  mock_outputs_allowed_terraform_commands = ["validate"]
  mock_outputs = {
    management_account_id   = "000000000000"
    environment_account_ids = {
      dev     = "111111111111"
      staging = "222222222222"
      prod    = "333333333333"
    }
  }
}

terraform {
  source = "../../../modules/identity-center-baseline"
}

inputs = {
  # IAM Identity Center is regional. Your instance is currently in us-east-1.
  aws_region = local.env.locals.identity_center_region

  admin_user_name  = local.env.locals.identity_center_admin_user_name
  admin_group_name = local.env.locals.identity_center_admin_group_name

  account_ids = merge(
    {
      management = dependency.organization.outputs.management_account_id
    },
    dependency.organization.outputs.environment_account_ids
  )

  common_tags = merge(
    {
      ManagedBy = "Terraform/Terragrunt"
      Project   = "veritrail-aws-baseline"
    },
    local.env.locals.global_tags,
    {
      Component = "identity-center"
    }
  )
}
