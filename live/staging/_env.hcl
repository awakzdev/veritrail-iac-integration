locals {
  environment = "staging"
  name_prefix = "veritrail"

  # Regional network settings.
  vpc_cidr            = "10.20.0.0/16"
  public_subnet_cidrs = ["10.20.1.0/24", "10.20.2.0/24"]

  # Empty by default: no inbound access until you opt in.
  allowed_ingress_cidrs = []
  allowed_ingress_ports = []

  # Exact names are controlled from Terragrunt.
  resource_names = {
    readonly_role                   = "veritrail-staging-readonly"
    security_audit_role             = "veritrail-staging-security-audit"
    cost_guardrail_policy           = "veritrail-staging-cost-guardrail"
    vpc                             = "veritrail-staging-vpc"
    internet_gateway                = "veritrail-staging-igw"
    public_route_table              = "veritrail-staging-public-rt"
    default_network_acl             = "veritrail-staging-default-nacl"
    default_security_group          = "veritrail-staging-default-locked-down"
    no_ingress_security_group       = "veritrail-staging-no-ingress"
    controlled_ingress_security_group = "veritrail-staging-controlled-ingress"
    s3_gateway_endpoint             = "veritrail-staging-s3-gateway-endpoint"
    dynamodb_gateway_endpoint       = "veritrail-staging-dynamodb-gateway-endpoint"
  }

  environment_tags = {
    Environment = "staging"
  }
}
