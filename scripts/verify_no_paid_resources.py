#!/usr/bin/env python3
"""
Static scanner for Terraform resource types that commonly create AWS charges.

This is not a formal billing guarantee. It catches the usual bill goblins before
someone invites them into the repo wearing a tiny NAT Gateway hat.
"""
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]

BANNED_RESOURCE_TYPES = {
    "aws_nat_gateway",
    "aws_instance",
    "aws_eip",
    "aws_lb",
    "aws_alb",
    "aws_elb",
    "aws_rds_cluster",
    "aws_db_instance",
    "aws_eks_cluster",
    "aws_eks_node_group",
    "aws_ecs_service",
    "aws_lambda_function",
    "aws_kms_key",
    "aws_config_configuration_recorder",
    "aws_config_config_rule",
    "aws_cloudwatch_log_group",
    "aws_cloudwatch_metric_alarm",
    "aws_route53_zone",
    "aws_s3_bucket",
    "aws_dynamodb_table",
    "aws_secretsmanager_secret",
    "aws_guardduty_detector",
    "aws_securityhub_account",
    "aws_inspector2_enabler",
    "aws_wafv2_web_acl",
    "aws_cloudfront_distribution",
}

RESOURCE_RE = re.compile(r'^\s*resource\s+"([^"]+)"\s+"([^"]+)"')

findings = []
for tf_file in ROOT.rglob("*.tf"):
    if ".terragrunt-cache" in tf_file.parts or ".terraform" in tf_file.parts:
        continue
    for line_no, line in enumerate(tf_file.read_text(encoding="utf-8").splitlines(), start=1):
        match = RESOURCE_RE.match(line)
        if not match:
            continue
        resource_type, resource_name = match.groups()
        if resource_type in BANNED_RESOURCE_TYPES:
            findings.append((tf_file.relative_to(ROOT), line_no, resource_type, resource_name))

if findings:
    print("Potential paid resources found:\n")
    for path, line_no, resource_type, resource_name in findings:
        print(f"- {path}:{line_no} resource {resource_type}.{resource_name}")
    sys.exit(1)

print("No banned paid resource types found. No-paid-resources-by-default shape is intact.")
