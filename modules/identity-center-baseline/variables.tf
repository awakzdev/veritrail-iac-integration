variable "aws_region" {
  description = "AWS region, passed by Terragrunt. IAM Identity Center has a primary region; use the same region where the instance was enabled."
  type        = string
}

variable "common_tags" {
  description = "Common tags. Identity Store resources do not support tags, but permission sets do."
  type        = map(string)
  default     = {}
}

variable "identity_center_instance_arn" {
  description = "Optional explicit IAM Identity Center instance ARN. Leave null to auto-detect the enabled organization instance."
  type        = string
  default     = null
}

variable "identity_store_id" {
  description = "Optional explicit Identity Store ID. Leave null to auto-detect it from IAM Identity Center."
  type        = string
  default     = null
}

variable "admin_user_name" {
  description = "Existing IAM Identity Center username to add to the admin group. This module looks the user up; it does not create the user by default."
  type        = string
}

variable "admin_group_name" {
  description = "IAM Identity Center group that receives account assignments."
  type        = string
  default     = "VeritrailAdmins"
}

variable "admin_group_description" {
  description = "Description for the admin Identity Center group."
  type        = string
  default     = "Veritrail administrators with AWS account access."
}

variable "account_ids" {
  description = "Map of account display names to AWS account IDs that should appear in the AWS access portal."
  type        = map(string)

  validation {
    condition = alltrue([
      for account_id in values(var.account_ids) :
      can(regex("^[0-9]{12}$", account_id))
    ])
    error_message = "Every account ID must be a 12-digit AWS account ID."
  }
}

variable "permission_sets" {
  description = "Permission sets to create in IAM Identity Center. Attach AWS managed policies by ARN."
  type = map(object({
    description             = string
    session_duration        = string
    aws_managed_policy_arns = list(string)
  }))

  default = {
    AdministratorAccess = {
      description             = "Full administrative access. Use carefully."
      session_duration        = "PT4H"
      aws_managed_policy_arns = ["arn:aws:iam::aws:policy/AdministratorAccess"]
    }
    ReadOnlyAccess = {
      description             = "Read-only AWS console and API access."
      session_duration        = "PT4H"
      aws_managed_policy_arns = ["arn:aws:iam::aws:policy/ReadOnlyAccess"]
    }
    SecurityAudit = {
      description             = "Security audit access for reviewing account posture."
      session_duration        = "PT4H"
      aws_managed_policy_arns = ["arn:aws:iam::aws:policy/SecurityAudit"]
    }
  }
}

variable "admin_account_assignment_permission_sets" {
  description = "Permission set names assigned to the admin group for every account in account_ids."
  type        = list(string)
  default     = ["AdministratorAccess"]

  validation {
    condition     = length(var.admin_account_assignment_permission_sets) > 0
    error_message = "At least one permission set must be assigned to the admin group."
  }
}
