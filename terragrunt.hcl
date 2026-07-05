locals {
  aws_region = get_env("AWS_REGION", "eu-west-1")
  root_dir   = get_terragrunt_dir()

  common_tags = {
    ManagedBy = "Terraform/Terragrunt"
    Project   = "aws-free-baseline"
  }
}

remote_state {
  backend = "local"

  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }

  config = {
    path = "${local.root_dir}/.state/${path_relative_to_include()}/terraform.tfstate"
  }
}

generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"

  contents = <<EOF
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = var.common_tags
  }
}
EOF
}

inputs = {
  aws_region  = local.aws_region
  common_tags = local.common_tags
}
