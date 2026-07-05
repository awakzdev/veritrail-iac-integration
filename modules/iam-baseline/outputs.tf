output "account_id" {
  description = "AWS account ID."
  value       = data.aws_caller_identity.current.account_id
}

output "readonly_role_arn" {
  description = "ARN of the read-only role."
  value       = try(aws_iam_role.readonly[0].arn, null)
}

output "security_audit_role_arn" {
  description = "ARN of the security audit role."
  value       = try(aws_iam_role.security_audit[0].arn, null)
}

output "cost_guardrail_policy_arn" {
  description = "ARN of the cost guardrail policy."
  value       = try(aws_iam_policy.cost_guardrail[0].arn, null)
}
