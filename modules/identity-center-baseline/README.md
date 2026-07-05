# Identity Center Baseline

Manages IAM Identity Center account access after the organization-level IAM Identity Center instance has been enabled once in the AWS console.

This module does not enable IAM Identity Center itself. It reads the existing instance, looks up an existing user, creates a Veritrail admin group, creates permission sets, and assigns the group to AWS accounts.

## What it creates

- `VeritrailAdmins` Identity Center group
- Group membership for an existing Identity Center user
- `AdministratorAccess`, `ReadOnlyAccess`, and `SecurityAudit` permission sets
- Account assignments for the admin group

## Important

The admin user must already exist in IAM Identity Center. If your username is not `Elazar`, update `identity_center_admin_user_name` in `live/global/_env.hcl` before applying.
