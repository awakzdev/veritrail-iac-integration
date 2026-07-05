locals {
  environment = "dev"
  name_prefix = "veritrail"

  # Regional network settings.
  vpc_cidr            = "10.10.0.0/16"
  public_subnet_cidrs = ["10.10.1.0/24", "10.10.2.0/24"]

  # Empty by default: no inbound access until you opt in.
  allowed_ingress_cidrs = []
  allowed_ingress_ports = []

  # Exact names are controlled from Terragrunt.
  resource_names = {
    readonly_role                   = "veritrail-dev-readonly"
    security_audit_role             = "veritrail-dev-security-audit"
    cost_guardrail_policy           = "veritrail-dev-cost-guardrail"
    vpc                             = "veritrail-dev-vpc"
    internet_gateway                = "veritrail-dev-igw"
    public_route_table              = "veritrail-dev-public-rt"
    default_network_acl             = "veritrail-dev-default-nacl"
    default_security_group          = "veritrail-dev-default-locked-down"
    no_ingress_security_group       = "veritrail-dev-no-ingress"
    controlled_ingress_security_group = "veritrail-dev-controlled-ingress"
    s3_gateway_endpoint             = "veritrail-dev-s3-gateway-endpoint"
    dynamodb_gateway_endpoint       = "veritrail-dev-dynamodb-gateway-endpoint"
  }

  environment_tags = {
    Environment = "dev"
  }
}
