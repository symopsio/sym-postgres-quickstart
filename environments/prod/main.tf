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

# Example RDS DB to demonstrate access grants and revokes with
module "db" {
  source = "../../modules/example-db"
  count  = var.db_enabled ? 1 : 0

  namespace = var.db_namespace
  tags      = var.tags
}

locals {
  connection_config  = var.db_enabled ? module.db[0].config : var.pg_connection_config
  security_group_ids = var.db_enabled ? [module.db[0].access_security_group_id] : var.lambda_security_group_ids
  subnet_ids         = var.db_enabled ? module.db[0].private_subnet_ids : var.lambda_subnet_ids
}

# Postgres access Lambda
module "postgres_lambda" {
  source = "../../modules/postgres-lambda"

  additional_security_group_ids = local.security_group_ids
  function_name                 = format("sym-postgres-%s", module.sym_runtime.environment.name)
  pg_connection_config          = local.connection_config
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
  targets          = var.pg_targets
}
