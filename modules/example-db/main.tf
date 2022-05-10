module "vpc" {
  source  = "cloudposse/vpc/aws"
  version = "= 0.28.1"

  namespace             = var.namespace
  cidr_block            = "10.0.0.0/16"
  dns_hostnames_enabled = true
  dns_support_enabled   = true
}

module "dynamic_subnets" {
  source  = "cloudposse/dynamic-subnets/aws"
  version = "= 0.39.8"

  namespace          = var.namespace
  availability_zones = ["us-east-1a", "us-east-1b"]
  vpc_id             = module.vpc.vpc_id
  igw_id             = module.vpc.igw_id
  cidr_block         = "10.0.0.0/16"
}

locals {
  rds_name = "${var.namespace}-example"
  db_name  = "${var.namespace}_master"
}

module "db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "~> 6.2.0"

  name          = local.rds_name
  database_name = local.db_name

  engine         = "aurora-postgresql"
  engine_version = "11.13"

  vpc_id = module.vpc.vpc_id

  subnets = module.dynamic_subnets.private_subnet_ids

  allowed_security_groups = concat(
    var.allowed_security_groups,
    [aws_security_group.bastion.id]
  )
  apply_immediately          = true
  monitoring_interval        = 0
  security_group_description = local.rds_name

  db_parameter_group_name         = aws_db_parameter_group.this.id
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.id

  instance_class = var.db_instance_type
  instances = {
    one = {}
  }

  enabled_cloudwatch_logs_exports = ["postgresql"]

  copy_tags_to_snapshot = true
  skip_final_snapshot   = true

  master_username        = local.db_name
  create_random_password = true

  tags = var.tags
}

resource "aws_db_parameter_group" "this" {
  name        = "${local.rds_name}-postgres11"
  family      = "aurora-postgresql11"
  description = "${local.rds_name}-postgres11"
}

resource "aws_rds_cluster_parameter_group" "this" {
  name        = "${local.rds_name}-postgres11-cluster"
  family      = "aurora-postgresql11"
  description = "${local.rds_name}-postgres11-cluster"

  parameter {
    name  = "rds.force_ssl"
    value = "1"
  }
}
