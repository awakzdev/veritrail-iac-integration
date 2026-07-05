locals {
  environment = "prod"
  name_prefix = "veritrail"

  # Regional network settings.
  vpc_cidr            = "10.30.0.0/16"
  public_subnet_cidrs = ["10.30.1.0/24", "10.30.2.0/24"]

  # Empty by default: no inbound access until you opt in.
  allowed_ingress_cidrs = []
  allowed_ingress_ports = []

  # Exact names are controlled from Terragrunt.
  resource_names = {
    readonly_role                   = "veritrail-prod-readonly"
    security_audit_role             = "veritrail-prod-security-audit"
    cost_guardrail_policy           = "veritrail-prod-cost-guardrail"
    vpc                             = "veritrail-prod-vpc"
    internet_gateway                = "veritrail-prod-igw"
    public_route_table              = "veritrail-prod-public-rt"
    default_network_acl             = "veritrail-prod-default-nacl"
    default_security_group          = "veritrail-prod-default-locked-down"
    no_ingress_security_group       = "veritrail-prod-no-ingress"
    controlled_ingress_security_group = "veritrail-prod-controlled-ingress"
    s3_gateway_endpoint             = "veritrail-prod-s3-gateway-endpoint"
    dynamodb_gateway_endpoint       = "veritrail-prod-dynamodb-gateway-endpoint"
  }

  environment_tags = {
    Environment = "prod"
  }
}
