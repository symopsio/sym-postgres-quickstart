output "lambda_arn" {
  description = "The arn of the lambda function"
  value       = aws_lambda_function.this.arn
}

output "pg_password_key" {
  description = "The name of the SSM Parameter for password configuration"
  value       = local.pg_password_key
}

output "security_group_id" {
  description = "The ID of the security group id for this lambda"
  value       = aws_security_group.this.id
}
