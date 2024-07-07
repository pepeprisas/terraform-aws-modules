output "efs_arn" {
  value       = aws_efs_file_system.efs.arn
  description = "EFS arn"
}

output "efs_ip" {
  value       = aws_efs_mount_target.efs.ip_address
  description = "EFS IP Address"
}

output "efs_id" {
  value       = aws_efs_file_system.efs.id
  description = "EFS ID"
}