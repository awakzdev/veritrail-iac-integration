output "identity_center_instance_arn" {
  description = "IAM Identity Center instance ARN used by this module."
  value       = local.instance_arn
}

output "identity_store_id" {
  description = "Identity Store ID used by this module."
  value       = local.identity_store_id
}

output "admin_group_id" {
  description = "Identity Store group ID for the admin group."
  value       = aws_identitystore_group.admins.group_id
}

output "admin_user_id" {
  description = "Identity Store user ID for the looked-up admin user."
  value       = data.aws_identitystore_user.admin.user_id
}

output "permission_set_arns" {
  description = "Permission set ARNs by name."
  value       = { for name, permission_set in aws_ssoadmin_permission_set.this : name => permission_set.arn }
}

output "assigned_accounts" {
  description = "Account IDs assigned to the admin group."
  value       = var.account_ids
}
