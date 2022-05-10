output "db_config" {
  description = "The config for the example db if enabled"
  sensitive   = true
  value       = var.db_enabled ? module.db[0].config : {}
}

output "pg_password_key" {
  description = "The name of the SSM Parameter for password configuration"
  value       = module.postgres_lambda.pg_password_key
}

output "lambda_arn" {
  description = "The arn of the lambda function"
  value       = module.postgres_lambda.lambda_arn
}
