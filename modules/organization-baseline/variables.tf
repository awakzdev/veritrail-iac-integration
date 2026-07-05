variable "aws_region" {
  description = "AWS region, passed by Terragrunt. AWS Organizations is global, but the provider still needs a region."
  type        = string
}

variable "common_tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}

variable "organization_name" {
  description = "Logical name used for tags and descriptions."
  type        = string
}

variable "workloads_ou_name" {
  description = "Name of the top-level OU that will contain environment OUs."
  type        = string
  default     = "workloads"
}

variable "organization_access_role_name" {
  description = "Role name automatically created inside new member accounts for management-account access."
  type        = string
  default     = "OrganizationAccountAccessRole"
}

variable "environment_accounts" {
  description = "Map of environment accounts to create. Each email must be unique and controlled by you."
  type = map(object({
    name  = string
    email = string
  }))

  validation {
    condition = alltrue([
      for account in values(var.environment_accounts) :
      can(regex("^[^@\\s]+@[^@\\s]+\\.[^@\\s]+$", account.email))
      && !can(regex("example\\.com$", lower(account.email)))
      && !can(regex("yourdomain\\.com$", lower(account.email)))
      && !can(regex("replace-me", lower(account.email)))
    ])
    error_message = "Every environment account needs a real, unique email address that you control. Replace the placeholder emails in live/global/_env.hcl."
  }
}

variable "create_cost_guardrail_scp" {
  description = "Create and attach a Service Control Policy that denies common bill-starting services/actions."
  type        = bool
  default     = true
}

variable "cost_guardrail_scp_name" {
  description = "Name of the cost guardrail SCP."
  type        = string
  default     = "veritrail-cost-guardrail"
}

variable "enabled_policy_types" {
  description = "Organization policy types to enable. SERVICE_CONTROL_POLICY is required for the optional SCP."
  type        = list(string)
  default     = ["SERVICE_CONTROL_POLICY"]
}

variable "aws_service_access_principals" {
  description = "AWS service principals that must keep trusted access enabled for the Organization. IAM Identity Center needs sso.amazonaws.com."
  type        = list(string)
  default     = ["sso.amazonaws.com"]
}
