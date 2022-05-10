variable "additional_security_group_ids" {
  description = "Additional security group IDs to add to the lambda"
  type        = list(string)
  default     = []
}

variable "function_name" {
  description = "Name of the Lambda function to create"
  type        = string
  default     = "sym-postgres"
}

variable "pg_connection_config" {
  description = "Connection configuration for your Postgres Database"
  type        = object({ host = string, port = number, user = string })
}

variable "pg_target_role" {
  description = "The target Postgres role to grant/revoke from users"
  type        = string
}

variable "subnet_ids" {
  description = "VPC subnet ids for the function"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
