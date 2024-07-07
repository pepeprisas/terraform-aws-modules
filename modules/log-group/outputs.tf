output "name" {
  value = aws_cloudwatch_log_group.ecs_log_group.name
}

output "arn" {
  value = aws_cloudwatch_log_group.ecs_log_group.arn
}