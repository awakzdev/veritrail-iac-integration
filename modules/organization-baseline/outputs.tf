output "management_account_id" {
  description = "AWS account ID of the management account running this module."
  value       = data.aws_caller_identity.current.account_id
}

output "organization_id" {
  description = "AWS Organization ID."
  value       = aws_organizations_organization.this.id
}

output "organization_arn" {
  description = "AWS Organization ARN."
  value       = aws_organizations_organization.this.arn
}

output "workloads_ou_id" {
  description = "Top-level workloads OU ID."
  value       = aws_organizations_organizational_unit.workloads.id
}

output "environment_ou_ids" {
  description = "Environment OU IDs by environment name."
  value       = { for env, ou in aws_organizations_organizational_unit.environment : env => ou.id }
}

output "environment_account_ids" {
  description = "Environment AWS account IDs by environment name."
  value       = { for env, account in aws_organizations_account.environment : env => account.id }
}

output "environment_account_arns" {
  description = "Environment AWS account ARNs by environment name."
  value       = { for env, account in aws_organizations_account.environment : env => account.arn }
}

output "environment_account_role_arns" {
  description = "Management-account assume-role ARNs for the created member accounts."
  value = {
    for env, account in aws_organizations_account.environment :
    env => "arn:${data.aws_partition.current.partition}:iam::${account.id}:role/${var.organization_access_role_name}"
  }
}

output "cost_guardrail_scp_id" {
  description = "Optional SCP ID."
  value       = try(aws_organizations_policy.cost_guardrail[0].id, null)
}
