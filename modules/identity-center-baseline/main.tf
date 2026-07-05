data "aws_ssoadmin_instances" "this" {}

data "aws_identitystore_user" "admin" {
  identity_store_id = local.identity_store_id

  alternate_identifier {
    unique_attribute {
      attribute_path  = "UserName"
      attribute_value = var.admin_user_name
    }
  }
}

locals {
  instance_arn      = var.identity_center_instance_arn != null ? var.identity_center_instance_arn : tolist(data.aws_ssoadmin_instances.this.arns)[0]
  identity_store_id = var.identity_store_id != null ? var.identity_store_id : tolist(data.aws_ssoadmin_instances.this.identity_store_ids)[0]

  tags = merge(var.common_tags, {
    Module    = "identity-center-baseline"
    Component = "identity-center"
  })

  managed_policy_attachments = merge([
    for permission_set_name, permission_set in var.permission_sets : {
      for policy_arn in permission_set.aws_managed_policy_arns :
      "${permission_set_name}|${policy_arn}" => {
        permission_set_name = permission_set_name
        policy_arn          = policy_arn
      }
    }
  ]...)

  admin_account_assignments = {
    for pair in setproduct(keys(var.account_ids), var.admin_account_assignment_permission_sets) :
    "${pair[0]}|${pair[1]}" => {
      account_name        = pair[0]
      account_id          = var.account_ids[pair[0]]
      permission_set_name = pair[1]
    }
  }
}

resource "aws_identitystore_group" "admins" {
  identity_store_id = local.identity_store_id
  display_name      = var.admin_group_name
  description       = var.admin_group_description
}

resource "aws_identitystore_group_membership" "admin_user" {
  identity_store_id = local.identity_store_id
  group_id          = aws_identitystore_group.admins.group_id
  member_id         = data.aws_identitystore_user.admin.user_id
}

resource "aws_ssoadmin_permission_set" "this" {
  for_each = var.permission_sets

  instance_arn     = local.instance_arn
  name             = each.key
  description      = each.value.description
  session_duration = each.value.session_duration

  tags = local.tags
}

resource "aws_ssoadmin_managed_policy_attachment" "this" {
  for_each = local.managed_policy_attachments

  instance_arn       = local.instance_arn
  managed_policy_arn = each.value.policy_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_name].arn
}

resource "aws_ssoadmin_account_assignment" "admins" {
  for_each = local.admin_account_assignments

  instance_arn       = local.instance_arn
  permission_set_arn = aws_ssoadmin_permission_set.this[each.value.permission_set_name].arn

  principal_id   = aws_identitystore_group.admins.group_id
  principal_type = "GROUP"

  target_id   = each.value.account_id
  target_type = "AWS_ACCOUNT"

  depends_on = [
    aws_identitystore_group_membership.admin_user,
    aws_ssoadmin_managed_policy_attachment.this
  ]
}
