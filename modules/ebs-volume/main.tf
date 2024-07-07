resource "aws_ebs_volume" "volume" {
  availability_zone = var.az
  size              = var.size
  iops              = var.iops

  tags = {
    Name = "${var.service}-${var.environment}-volume"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}
