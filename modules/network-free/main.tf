data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  tags = merge(var.common_tags, {
    Environment = var.environment
    Module      = "network-free"
  })

  azs = length(var.availability_zones) > 0 ? var.availability_zones : slice(data.aws_availability_zones.available.names, 0, 2)

  public_subnet_cidrs = length(var.public_subnet_cidrs) > 0 ? var.public_subnet_cidrs : [
    cidrsubnet(var.vpc_cidr, 8, 1),
    cidrsubnet(var.vpc_cidr, 8, 2)
  ]

  ingress_rules = flatten([
    for cidr in var.allowed_ingress_cidrs : [
      for port in var.allowed_ingress_ports : {
        cidr = cidr
        port = port
      }
    ]
  ])
}

resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-${var.environment}-vpc"
  })
}

resource "aws_internet_gateway" "this" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-${var.environment}-igw"
  })
}

resource "aws_subnet" "public" {
  for_each = {
    for index, cidr in local.public_subnet_cidrs : tostring(index) => cidr
  }

  vpc_id                  = aws_vpc.this.id
  cidr_block              = each.value
  availability_zone       = local.azs[tonumber(each.key) % length(local.azs)]
  map_public_ip_on_launch = false

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-${var.environment}-public-${tonumber(each.key) + 1}"
    Tier = "public"
  })
}

resource "aws_route_table" "public" {
  count  = var.create_internet_gateway ? 1 : 0
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this[0].id
  }

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-${var.environment}-public-rt"
  })
}

resource "aws_route_table_association" "public" {
  for_each = var.create_internet_gateway ? aws_subnet.public : {}

  subnet_id      = each.value.id
  route_table_id = aws_route_table.public[0].id
}

resource "aws_default_network_acl" "default" {
  default_network_acl_id = aws_vpc.this.default_network_acl_id

  # Keep default NACL permissive, because NACLs are stateless and easy to break.
  # Security is enforced with locked-down security groups by default.
  ingress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  egress {
    protocol   = -1
    rule_no    = 100
    action     = "allow"
    cidr_block = "0.0.0.0/0"
    from_port  = 0
    to_port    = 0
  }

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-${var.environment}-default-nacl"
  })
}

resource "aws_default_security_group" "locked_down" {
  vpc_id = aws_vpc.this.id

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-${var.environment}-default-locked-down"
  })
}

resource "aws_security_group" "no_ingress" {
  name        = "${var.name_prefix}-${var.environment}-no-ingress"
  description = "No ingress; HTTPS egress only."
  vpc_id      = aws_vpc.this.id

  egress {
    description = "HTTPS egress only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-${var.environment}-no-ingress"
  })
}

resource "aws_security_group" "controlled_ingress" {
  name        = "${var.name_prefix}-${var.environment}-controlled-ingress"
  description = "Ingress only from explicitly configured CIDRs and ports."
  vpc_id      = aws_vpc.this.id

  dynamic "ingress" {
    for_each = {
      for idx, rule in local.ingress_rules : tostring(idx) => rule
    }

    content {
      description = "Configured TCP ingress"
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "tcp"
      cidr_blocks = [ingress.value.cidr]
    }
  }

  egress {
    description = "HTTPS egress only"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-${var.environment}-controlled-ingress"
  })
}

resource "aws_vpc_endpoint" "s3_gateway" {
  count = var.create_gateway_endpoints && var.create_internet_gateway ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public[0].id]

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-${var.environment}-s3-gateway-endpoint"
  })
}

resource "aws_vpc_endpoint" "dynamodb_gateway" {
  count = var.create_gateway_endpoints && var.create_internet_gateway ? 1 : 0

  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${var.aws_region}.dynamodb"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.public[0].id]

  tags = merge(local.tags, {
    Name = "${var.name_prefix}-${var.environment}-dynamodb-gateway-endpoint"
  })
}
