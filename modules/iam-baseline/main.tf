data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  tags = merge(var.common_tags, {
    Environment = var.environment
    Module      = "iam-baseline"
  })

  trusted_principals = length(var.trusted_aws_principal_arns) > 0 ? var.trusted_aws_principal_arns : ["arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"]

  readonly_role_name       = lookup(var.resource_names, "readonly_role", "${var.name_prefix}-${var.environment}-readonly")
  security_audit_role_name = lookup(var.resource_names, "security_audit_role", "${var.name_prefix}-${var.environment}-security-audit")
  guardrail_policy_name    = lookup(var.resource_names, "cost_guardrail_policy", "${var.name_prefix}-${var.environment}-cost-guardrail")
}

resource "aws_iam_account_password_policy" "this" {
  count = var.create_account_password_policy ? 1 : 0

  minimum_password_length        = 14
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  hard_expiry                    = false
  max_password_age               = 90
  password_reuse_prevention      = 24
}

resource "aws_iam_account_alias" "this" {
  count         = var.create_account_alias && var.account_alias != null ? 1 : 0
  account_alias = var.account_alias
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    sid     = "AllowTrustedAwsPrincipals"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = local.trusted_principals
    }
  }
}

resource "aws_iam_policy" "cost_guardrail" {
  count = var.create_cost_guardrail_policy ? 1 : 0

  name        = local.guardrail_policy_name
  description = "Explicit deny guardrail for common AWS resources that can start charges. Not exhaustive."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyCommonComputeAndDataPlaneCostStarters"
        Effect = "Deny"
        Action = [
          "ec2:RunInstances",
          "ec2:CreateNatGateway",
          "ec2:AllocateAddress",
          "ec2:CreateLaunchTemplate",
          "ec2:CreateCapacityReservation",
          "elasticloadbalancing:CreateLoadBalancer",
          "rds:CreateDBInstance",
          "rds:CreateDBCluster",
          "eks:CreateCluster",
          "eks:CreateNodegroup",
          "ecs:CreateCluster",
          "ecs:CreateService",
          "lambda:CreateFunction",
          "dynamodb:CreateTable",
          "s3:CreateBucket",
          "kms:CreateKey",
          "route53:CreateHostedZone",
          "config:PutConfigurationRecorder",
          "config:StartConfigurationRecorder",
          "cloudwatch:PutMetricAlarm",
          "logs:CreateLogGroup",
          "secretsmanager:CreateSecret",
          "guardduty:CreateDetector",
          "securityhub:EnableSecurityHub",
          "inspector2:Enable",
          "wafv2:CreateWebACL",
          "cloudfront:CreateDistribution"
        ]
        Resource = "*"
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role" "readonly" {
  count = var.create_readonly_role ? 1 : 0

  name               = local.readonly_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  description        = "Read-only role for ${var.environment}."

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "readonly_managed" {
  count = var.create_readonly_role ? 1 : 0

  role       = aws_iam_role.readonly[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "readonly_guardrail" {
  count = var.create_readonly_role && var.attach_cost_guardrail_to_roles && var.create_cost_guardrail_policy ? 1 : 0

  role       = aws_iam_role.readonly[0].name
  policy_arn = aws_iam_policy.cost_guardrail[0].arn
}

resource "aws_iam_role" "security_audit" {
  count = var.create_security_audit_role ? 1 : 0

  name               = local.security_audit_role_name
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
  description        = "Security audit role for ${var.environment}."

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "security_audit_managed" {
  count = var.create_security_audit_role ? 1 : 0

  role       = aws_iam_role.security_audit[0].name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/SecurityAudit"
}

resource "aws_iam_role_policy_attachment" "security_audit_guardrail" {
  count = var.create_security_audit_role && var.attach_cost_guardrail_to_roles && var.create_cost_guardrail_policy ? 1 : 0

  role       = aws_iam_role.security_audit[0].name
  policy_arn = aws_iam_policy.cost_guardrail[0].arn
}
