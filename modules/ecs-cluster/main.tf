resource "aws_ecs_cluster" "main" {
  name = "${var.account}-${terraform.workspace}-${var.service}-ecsCluster"

  tags = {
    Environment = terraform.workspace
    Name  = "${var.account}-${terraform.workspace}-${var.service}-ecsCluster"
    Country = var.account
    Resource = "ecsCluster"
    Environment = terraform.workspace
    Service = var.service
  }
}
