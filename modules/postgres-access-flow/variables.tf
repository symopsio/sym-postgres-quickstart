variable "flow_vars" {
  description = "Configuration values for the Flow implementation Python."
  type        = map(string)
}

variable "lambda_arn" {
  description = "The target AWS Lambda ARN that the flow will invoke"
  type        = string
}

variable "runtime_settings" {
  description = "Runtime connector settings"
  type        = object({ role_arn = string })
}

variable "sym_environment" {
  description = "Sym Environment for this Flow."
  type        = object({ id = string, name = string })
}

variable "tags" {
  description = "Additional tags to apply to resources."
  type        = map(string)
  default     = {}
}
