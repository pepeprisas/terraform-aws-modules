output "db_username" {
  value       = aws_db_instance.mariadb.username
  description = "Database Username"
}

output "db_database" {
  value       = aws_db_instance.mariadb.name
  description = "Database Name"
}

output "db_address" {
  value       = aws_db_instance.mariadb.address
  description = "Database Address"
}

output "db_port" {
  value       = aws_db_instance.mariadb.port
  description = "Database Port"
}

output "db_host" {
  value       = var.hostname
  description = "Database Host"
}

output "db_secret" {
  value       = aws_secretsmanager_secret.mariadb_secret.name
  description = "Database Credentials Secret"
}

output "db_secret_arn" {
  value       = aws_secretsmanager_secret.mariadb_secret.arn
  description = "Database Credentials Secret ARN"
}