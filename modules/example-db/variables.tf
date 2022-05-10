variable "allowed_security_groups" {
  description = "A list of Security Group IDs to allow access to"
  type        = list(string)
  default     = []
}

variable "db_instance_type" {
  description = "Type of the DB instance"
  type        = string
  default     = "db.t3.medium"
}

variable "namespace" {
  description = "Namespace qualifier"
  type        = string
  default     = "sym"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}
