resource "aws_cloudwatch_log_group" "ecs_log_group" {
  name = "/aws/ecs/${var.environment}/${var.service}"

  tags = {
    Name = "${var.service}-${var.environment}-log-group"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}
