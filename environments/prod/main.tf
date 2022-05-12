provider "aws" {
  region = var.aws_region
}

provider "sym" {
  org = var.sym_org_slug
}

# A Sym Runtime that executes your Flows.
module "sym_runtime" {
  source = "../../modules/sym-runtime"

  error_channel      = var.error_channel
  runtime_name       = var.runtime_name
  slack_workspace_id = var.slack_workspace_id
  sym_account_ids    = var.sym_account_ids
  tags               = var.tags
}

locals {
  connection_config  = var.db_enabled ? module.db[0].config : var.pg_connection_config
  function_name      = "sym-postgres-${module.sym_runtime.environment.name}"
  security_group_ids = var.db_enabled ? [aws_security_group.lambda_db_access[0].id] : []
  subnet_ids         = var.db_enabled ? module.db[0].private_subnet_ids : var.lambda_subnet_ids
}

# Allow the lambda outbound to the example DB
resource "aws_security_group_rule" "lambda_db_egress" {
  count = var.db_enabled ? 1 : 0

  source_security_group_id = module.db[0].security_group_id
  security_group_id        = aws_security_group.lambda_db_access[0].id

  description = "To RDS"
  type        = "egress"
  protocol    = "tcp"
  to_port     = module.db[0].config["port"]
  from_port   = module.db[0].config["port"]
}

# Security group that allows the lambda to access the example db
resource "aws_security_group" "lambda_db_access" {
  count = var.db_enabled ? 1 : 0

  name        = "${local.function_name}-db"
  description = "${local.function_name} example db access"
  tags        = var.tags
  vpc_id      = module.db[0].vpc_id
}

# Example RDS DB to demonstrate access grants and revokes with
module "db" {
  source = "../../modules/example-db"
  count  = var.db_enabled ? 1 : 0

  allowed_security_groups = local.security_group_ids
  namespace               = var.namespace
  tags                    = var.tags
}

# Postgres access Lambda
module "postgres_lambda" {
  source = "../../modules/postgres-lambda"

  additional_security_group_ids = local.security_group_ids
  function_name                 = local.function_name
  pg_connection_config          = local.connection_config
  pg_target_role                = var.pg_target_role
  subnet_ids                    = local.subnet_ids
  tags                          = var.tags
}

# A Flow that uses the postgres access Lambda
module "postgres_flow" {
  source = "../../modules/postgres-flow"

  flow_vars        = var.flow_vars
  lambda_arn       = module.postgres_lambda.lambda_arn
  runtime_settings = module.sym_runtime.runtime_settings
  sym_environment  = module.sym_runtime.environment
  tags             = var.tags
}
