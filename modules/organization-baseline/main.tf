data "aws_partition" "current" {}

data "aws_caller_identity" "current" {}

locals {
  tags = merge(var.common_tags, {
    Module           = "organization-baseline"
    OrganizationName = var.organization_name
  })

  environments = keys(var.environment_accounts)
}

resource "aws_organizations_organization" "this" {
  feature_set          = "ALL"
  enabled_policy_types = var.enabled_policy_types
}

resource "aws_organizations_organizational_unit" "workloads" {
  name      = var.workloads_ou_name
  parent_id = aws_organizations_organization.this.roots[0].id

  tags = local.tags
}

resource "aws_organizations_organizational_unit" "environment" {
  for_each = var.environment_accounts

  name      = each.key
  parent_id = aws_organizations_organizational_unit.workloads.id

  tags = merge(local.tags, {
    Environment = each.key
  })
}

resource "aws_organizations_account" "environment" {
  for_each = var.environment_accounts

  name                       = each.value.name
  email                      = each.value.email
  parent_id                  = aws_organizations_organizational_unit.environment[each.key].id
  role_name                  = var.organization_access_role_name
  iam_user_access_to_billing = "DENY"

  # Important safety default: removing this resource from Terraform should not close
  # the AWS account. The lifecycle block also prevents accidental destroy.
  close_on_deletion = false

  tags = merge(local.tags, {
    Environment = each.key
    AccountType = "environment"
  })

  lifecycle {
    prevent_destroy = true

    # These fields are creation-time settings. After importing existing member accounts,
    # the AWS provider may plan a replacement because the API does not return them in
    # the same shape. Never replace accounts just to reconcile these attributes.
    ignore_changes = [
      iam_user_access_to_billing,
      role_name,
    ]
  }
}

resource "aws_organizations_policy" "cost_guardrail" {
  count = var.create_cost_guardrail_scp ? 1 : 0

  name        = var.cost_guardrail_scp_name
  description = "Veritrail baseline SCP: denies common AWS actions that usually create direct charges. Not exhaustive."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyCommonChargeStartingActions"
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

  depends_on = [aws_organizations_organization.this]
}

resource "aws_organizations_policy_attachment" "cost_guardrail_workloads" {
  count = var.create_cost_guardrail_scp ? 1 : 0

  policy_id = aws_organizations_policy.cost_guardrail[0].id
  target_id = aws_organizations_organizational_unit.workloads.id
}
