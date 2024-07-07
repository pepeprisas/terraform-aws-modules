output "efs_access_point_id" {
  value       = aws_efs_access_point[*].id
  description = "EFS access point id"
}
