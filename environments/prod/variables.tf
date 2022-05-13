variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}

variable "db_enabled" {
  description = "Whether or not create the example db"
  type        = bool
  default     = false
}

variable "db_namespace" {
  description = "Namespace qualifier for example resources"
  type        = string
  default     = "sym"
  validation {
    condition     = can(regex("[[:alpha:]]+", var.db_namespace))
    error_message = "Namespace must be alphabetic chars."
  }
}

variable "error_channel" {
  description = "The error channel to use to surface Sym errors."
  type        = string
  default     = "#sym-errors"
  validation {
    condition     = can(regex("^#.+", var.error_channel))
    error_message = "Error channel should start with #."
  }
}

variable "flow_vars" {
  description = "Configuration values for the Flow implementation Python"
  type        = map(string)
  default     = {}
}

variable "lambda_security_group_ids" {
  description = "Additional security group IDs for the lambda function."
  type        = list(string)
  default     = []
}

variable "lambda_subnet_ids" {
  description = "The subnet IDs to put the lambda function in. You must either enable the example DB or provide subnet IDs here"
  type        = list(string)
  default     = []
}

variable "pg_connection_config" {
  description = "You must either provide db config or enable the example db."
  type        = object({ host = string, port = number, user = string })
  default     = { host = "changeme", port = 5432, user = "changeme" }
}

variable "pg_targets" {
  description = "The target roles that users can request access to"
  type = list(object(
    { role_name = string, label = string }
  ))
}

variable "runtime_name" {
  description = "Name to assign to the Sym Runtime and its associated resources."
  type        = string
  default     = "prod"
}

variable "slack_workspace_id" {
  description = "The Slack Workspace ID to use for your Slack integration"
  type        = string
}

variable "sym_account_ids" {
  description = "List of account ids that can assume the Sym runtime role. By default, only Sym production accounts can assume the runtime role."
  type        = list(string)
  default     = ["803477428605"]
}

variable "sym_org_slug" {
  description = "Sym org slug for your org"
  type        = string
  validation {
    condition     = can(regex("[[:alnum:]]+", var.sym_org_slug))
    error_message = "The org slug must be alphanumeric."
  }
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
