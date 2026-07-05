locals {
  organization_name = "veritrail"
  name_prefix       = "veritrail"

  # These emails must be unique AWS account emails that you control.
  # Plus-addressing usually works if your mailbox supports it, for example:
  # aws-dev@veritrail.io, aws-staging@veritrail.io, etc.
  environment_accounts = {
    dev = {
      name  = "veritrail-dev"
      email = "aws-dev@veritrail.io"
    }
    staging = {
      name  = "veritrail-staging"
      email = "aws-staging@veritrail.io"
    }
    prod = {
      name  = "veritrail-prod"
      email = "aws-prod@veritrail.io"
    }
  }

  workloads_ou_name             = "workloads"
  organization_access_role_name = "OrganizationAccountAccessRole"

  # Strong default for a cost-guarded lab. Set false if you intentionally want to allow paid resources later.
  create_cost_guardrail_scp = true
  cost_guardrail_scp_name   = "veritrail-cost-guardrail"

  # IAM Identity Center must be enabled once from the AWS console before applying live/global/identity-center.
  # Your current Identity Center primary region is us-east-1.
  # The user name must match the existing Identity Center username that logs into the AWS access portal.
  identity_center_region          = "us-east-1"
  identity_center_admin_user_name = "Elazar"
  identity_center_admin_group_name = "VeritrailAdmins"

  # Optional. Disabled because account aliases are global and only one can exist per account.
  create_account_alias = false
  account_alias        = "veritrail-management"

  global_tags = {
    Scope = "global"
  }
}
