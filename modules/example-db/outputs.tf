output "access_security_group_id" {
  description = "Security group that allows egress to the DB"
  value       = aws_security_group.db_access.id
}

output "config" {
  description = "The config for the example db if enabled"
  sensitive   = true
  value = {
    "host" = module.db.cluster_endpoint
    "port" = module.db.cluster_port
    "user" = module.db.cluster_master_username
    "pass" = module.db.cluster_master_password
  }
}

output "private_subnet_ids" {
  value = module.dynamic_subnets.private_subnet_ids
}

output "security_group_id" {
  description = "DB Security Group ID"
  value       = module.db.security_group_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
