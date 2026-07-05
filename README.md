# Veritrail AWS Baseline, Terraform + Terragrunt

A multi-account, multi-environment AWS baseline for `veritrail.io`, designed to avoid creating resources that commonly start direct AWS charges.

This repo can create, from one AWS management account:

- An AWS Organization
- A `workloads` OU
- `dev`, `staging`, and `prod` OUs
- One AWS member account per environment
- An optional Service Control Policy that denies common bill-starting actions
- IAM Identity Center permission sets and account assignments after Identity Center is enabled once
- Environment IAM baselines and networking deployed by assuming into each member account

It creates only AWS resources that usually have no standalone hourly charge:

- AWS Organizations, OUs, accounts, and SCPs
- IAM Identity Center groups, permission sets, and account assignments
- IAM password policies, roles, managed policies, and optional account alias
- VPC, subnets, route tables, network ACLs, Internet Gateway, and security groups
- Optional S3/DynamoDB gateway VPC endpoints, disabled by default

It intentionally does **not** create NAT Gateways, EC2 instances, EIPs, RDS, EKS, load balancers, KMS keys, AWS Config, CloudWatch log groups, Route 53 hosted zones, S3 buckets, DynamoDB tables, Secrets Manager secrets, GuardDuty, Security Hub, Inspector, WAF, or CloudFront.

> Important: AWS Organizations and IAM Identity Center have no standalone service charge, but the management account pays for resources used inside member accounts. This project is a “no paid resources by default” scaffold, not a legal pricing guarantee.

---

## Repository layout

```text
.
├── modules
│   ├── organization-baseline
│   ├── identity-center-baseline
│   ├── iam-baseline
│   └── network-baseline
├── live
│   ├── global
│   │   ├── _env.hcl
│   │   ├── organization
│   │   ├── identity-center
│   │   └── account
│   ├── dev
│   │   ├── _env.hcl
│   │   ├── account
│   │   └── network
│   ├── staging
│   │   ├── _env.hcl
│   │   ├── account
│   │   └── network
│   └── prod
│       ├── _env.hcl
│       ├── account
│       └── network
├── scripts
│   └── verify_no_paid_resources.py
├── terragrunt.hcl
└── .gitignore
```

---

## Architecture

```text
AWS management account
├── AWS Organization
│   └── workloads OU
│       ├── dev OU
│       │   └── veritrail-dev AWS account
│       ├── staging OU
│       │   └── veritrail-staging AWS account
│       └── prod OU
│           └── veritrail-prod AWS account
├── IAM Identity Center
│   ├── VeritrailAdmins group
│   ├── AdministratorAccess / ReadOnlyAccess / SecurityAudit permission sets
│   └── AWS access portal assignments for management/dev/staging/prod
└── management IAM baseline
```

Terragrunt deploys `live/dev`, `live/staging`, and `live/prod` by assuming the Organization-created role inside each member account:

```text
arn:aws:iam::<environment-account-id>:role/OrganizationAccountAccessRole
```

---

## Veritrail account emails

The account emails are already set in:

```text
live/global/_env.hcl
```

```hcl
locals {
  environment_accounts = {
    dev = {
      name  = "veritrail-dev"
      email = "aws-dev@veritrail.io"
    }
    staging = {
      name  = "veritrail-staging"
      email = "aws-staging@veritrail.io"
    }
    prod = {
      name  = "veritrail-prod"
      email = "aws-prod@veritrail.io"
    }
  }
}
```

Before applying, confirm those addresses can receive mail through your `veritrail.io` catch-all. AWS requires each account email to be unique and not already used by another AWS account.

---

## IAM Identity Center settings

IAM Identity Center must be enabled once from the AWS Console. After that, Terraform/Terragrunt can manage the account access model.

The admin user lookup is configured in:

```text
live/global/_env.hcl
```

```hcl
identity_center_admin_user_name  = "Elazar"
identity_center_admin_group_name = "VeritrailAdmins"
```

The user must already exist in IAM Identity Center. If your portal username is different, edit `identity_center_admin_user_name` before applying `live/global/identity-center`.

The identity-center stack creates:

- `VeritrailAdmins` group
- membership for the existing admin user
- `AdministratorAccess`, `ReadOnlyAccess`, and `SecurityAudit` permission sets
- `AdministratorAccess` assignment for management, dev, staging, and prod accounts

After it applies, the AWS access portal should show all assigned accounts.

---

## Resource names are Terragrunt inputs

Each environment has exact names in its `_env.hcl` file:

```hcl
locals {
  environment = "dev"
  name_prefix = "veritrail"

  resource_names = {
    readonly_role                     = "veritrail-dev-readonly"
    security_audit_role               = "veritrail-dev-security-audit"
    cost_guardrail_policy             = "veritrail-dev-cost-guardrail"
    vpc                               = "veritrail-dev-vpc"
    internet_gateway                  = "veritrail-dev-igw"
    public_route_table                = "veritrail-dev-public-rt"
    default_network_acl               = "veritrail-dev-default-nacl"
    default_security_group            = "veritrail-dev-default-locked-down"
    no_ingress_security_group         = "veritrail-dev-no-ingress"
    controlled_ingress_security_group = "veritrail-dev-controlled-ingress"
    s3_gateway_endpoint               = "veritrail-dev-s3-gateway-endpoint"
    dynamodb_gateway_endpoint         = "veritrail-dev-dynamodb-gateway-endpoint"
  }
}
```

Resource naming is controlled from Terragrunt, not hardcoded inside the modules.

---

## Prerequisites

- Terraform `>= 1.6`
- Terragrunt `>= 0.55`
- AWS CLI authenticated to the AWS account that should become the **management account**
- Billing/contact setup completed in that management account
- `veritrail.io` mail catch-all working for the account emails above
- IAM Identity Center enabled once in the AWS Console before applying `live/global/identity-center`
- An existing IAM Identity Center user matching `identity_center_admin_user_name`

Use an IAM admin role/user in the management account. Avoid using the AWS root user for normal Terraform work.

Check which account your CLI is currently using:

```bash
aws sts get-caller-identity
```

Set a specific CLI profile if needed:

```bash
export AWS_PROFILE=veritrail-management
aws sts get-caller-identity
```

Set a region if you do not want the default:

```bash
export AWS_REGION=eu-west-1
```

---

## Safety check before apply

Run the static guardrail scanner:

```bash
python3 scripts/verify_no_paid_resources.py
```

This looks for common paid resource types that should not appear in this repository.

---

## Apply order

### 1. Create or reconcile the AWS Organization and environment accounts

```bash
cd live/global/organization
terragrunt plan
terragrunt apply
```

AWS account creation can take a few minutes. If the next step fails with an STS assume-role error, wait a little and run it again.

If you had to import the Organization/accounts after losing local state, make sure the plan does not replace `aws_organizations_account.environment[*]`. The account resource ignores create-time attributes that otherwise cause replacement after import.

### 2. Apply Identity Center account assignments

Only run this after enabling IAM Identity Center once in the AWS Console and creating the admin user.

```bash
cd ../identity-center
terragrunt plan
terragrunt apply
```

If the user lookup fails, edit `identity_center_admin_user_name` in `live/global/_env.hcl` to match the IAM Identity Center username shown in the console.

### 3. Apply management-account IAM baseline

```bash
cd ../account
terragrunt plan
terragrunt apply
```

### 4. Apply an environment

```bash
cd ../../dev
terragrunt run-all plan
terragrunt run-all apply
```

Repeat for staging or prod:

```bash
cd ../staging
terragrunt run-all apply

cd ../prod
terragrunt run-all apply
```

---

## Authentication model

You authenticate only to the existing AWS account that will act as the management account.

That first apply creates the Organization and member accounts. For the environment applies, Terragrunt reads the account IDs from the organization dependency output and assumes this role inside each member account:

```text
OrganizationAccountAccessRole
```

You do not manually log in to the new dev/staging/prod accounts for the Terraform flow.

For human console access, use the AWS access portal after the Identity Center stack assigns the `VeritrailAdmins` group to each account.

---

## Existing AWS Organizations

This repository assumes the authenticated account is not already part of another AWS Organization as a member account. If the account already owns an Organization, import the existing Organization into state or adapt `modules/organization-baseline` to manage only the OUs/accounts.

Do not run this from an unrelated AWS account by accident. The account returned by `aws sts get-caller-identity` becomes the place where the Organization is managed.

---

## State backend

This scaffold uses local Terraform state by default:

```hcl
remote_state {
  backend = "local"
}
```

This avoids creating an S3 bucket and DynamoDB table. For team usage, replace this with an encrypted remote backend that already exists, or intentionally create a backend after accepting the small storage/request cost.

---

## Cost guardrail SCP

The optional SCP denies a list of common charge-starting actions across the `workloads` OU, including EC2, NAT Gateways, RDS, EKS, Lambda, S3 buckets, KMS keys, Route 53 hosted zones, AWS Config, CloudWatch alarms/log groups, GuardDuty, Security Hub, Inspector, WAF, and CloudFront.

It is intentionally conservative. It is not a complete billing firewall. Budgets, alerts, IAM least privilege, and periodic cost review are still recommended.

---

## Things this repo avoids by default

| Resource | Why avoided |
|---|---|
| NAT Gateway | Hourly and data processing charges |
| EC2 instances | Compute charges |
| Elastic IP | Can incur charges, especially unattached |
| RDS / EKS / Load Balancers | Direct service charges |
| KMS customer managed keys | Monthly key charges |
| AWS Config | Configuration item and rule evaluation charges |
| CloudWatch logs / alarms | Ingestion, storage, or alarm charges |
| Route 53 hosted zones | Monthly hosted-zone charges |
| S3 buckets | Storage/request charges |
| DynamoDB tables | Capacity/request/storage charges depending on mode and usage |
| GuardDuty / Security Hub / Inspector | Paid security services after trial periods |

---

## Destroy behavior

Environment resources can be destroyed normally, but AWS account resources have:

```hcl
close_on_deletion = false

lifecycle {
  prevent_destroy = true
}
```

This prevents Terraform from accidentally closing member accounts. If you ever want to close an AWS account, do it deliberately through the AWS account closure flow.
