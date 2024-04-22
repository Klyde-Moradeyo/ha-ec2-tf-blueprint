output "name" {
  description = "Generated name from local configuration."
  value       = module.resource_name_prefix.resource_name
}

output "db_instance_address" {
  value       = aws_db_instance.db.address
  description = "The address of the RDS instance"
}

output "db_instance_arn" {
  value       = aws_db_instance.db.arn
  description = "The ARN of the RDS instance"
}
