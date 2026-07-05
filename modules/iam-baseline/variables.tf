variable "aws_region" {
  description = "AWS region, passed by Terragrunt. IAM is global but the provider still needs a region."
  type        = string
}

variable "environment" {
  description = "Environment name, for example dev, staging, prod, or management."
  type        = string
}

variable "name_prefix" {
  description = "Fallback name prefix for all IAM resources when resource_names does not override them."
  type        = string
}

variable "resource_names" {
  description = "Exact resource names, usually provided from Terragrunt. Missing keys fall back to generated names."
  type        = map(string)
  default     = {}
}

variable "common_tags" {
  description = "Common tags."
  type        = map(string)
  default     = {}
}

variable "create_account_password_policy" {
  description = "Create or manage the account password policy."
  type        = bool
  default     = true
}

variable "create_account_alias" {
  description = "Create an AWS account alias. Only one alias can exist per account, so this is disabled by default."
  type        = bool
  default     = false
}

variable "account_alias" {
  description = "AWS account alias to create when create_account_alias is true."
  type        = string
  default     = null
}

variable "trusted_aws_principal_arns" {
  description = "AWS principals allowed to assume the created roles. Defaults to the current account root."
  type        = list(string)
  default     = []
}

variable "create_readonly_role" {
  description = "Create a ReadOnlyAccess role."
  type        = bool
  default     = true
}

variable "create_security_audit_role" {
  description = "Create a SecurityAudit role."
  type        = bool
  default     = true
}

variable "create_cost_guardrail_policy" {
  description = "Create a policy that explicitly denies common bill-starting actions."
  type        = bool
  default     = true
}

variable "attach_cost_guardrail_to_roles" {
  description = "Attach the cost guardrail policy to the created roles."
  type        = bool
  default     = true
}
