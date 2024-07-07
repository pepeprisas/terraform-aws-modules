data "aws_subnet" "selected" {
  id = var.subnet-id
}


# Traffic to the ECS Cluster should only come from the ALB
resource "aws_security_group" "ecs-task-sg" {
  name = "${var.account}-${terraform.workspace}-${var.service}-ecsTaskSG"
  description = "Task security group. Allows traffic from the ALB."
  vpc_id = data.aws_subnet.selected.vpc_id

  dynamic "ingress" {
    for_each = [for p in var.container-exposed-port: {
      port = p.port
      protocol = p.protocol
      cidr_blocks = p.cidr_blocks
    }]
    content {
      protocol = ingress.value.protocol
      from_port = ingress.value.port
      to_port = ingress.value.port
      security_groups = ingress.value.cidr_blocks != null ? [] : [var.alb-sg-id]
      cidr_blocks = ingress.value.cidr_blocks != null ? ingress.value.cidr_blocks : []
    }
  }

  egress {
    protocol = "-1"
    from_port = 0
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Environment = terraform.workspace
    Name  = "${var.account}-${terraform.workspace}-${var.service}-ecsTaskSG-"
    Account = var.account
    Resource = "ecsTaskSG"
    Service = var.service
  }
}

locals {
  add_volume = var.add_volume
}

resource "aws_ecs_task_definition" "ecs-task-definition" {
  family = "${var.account}-${terraform.workspace}-${var.service}-taskFamily"
  requires_compatibilities = ["FARGATE"]
  network_mode = "awsvpc"
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn = var.task_role_arn
  task_role_arn = var.task_role_arn

  dynamic "volume" {
    for_each = [for v in local.add_volume: {
      efs_id = v.efs_id
      volume_name = v.volume_name
      root_directory = v.root_directory
      file_system_id = v.file_system_id
    }]
    content {
      name = volume.value.volume_name

      efs_volume_configuration {
        file_system_id          = volume.value.efs_id
        root_directory          = volume.value.root_directory
        transit_encryption      = "ENABLED"
        authorization_config {
          access_point_id = volume.value.file_system_id
        }
      }
    }
  }


  container_definitions = var.container-definitions

  tags = {
    Environment = terraform.workspace
    Name  = "${var.account}-${terraform.workspace}-${var.service}-ecsTaskDefinition"
    Account = var.account
    Resource = "ecsTaskDefinition"
    Service = var.service
  }
}

resource "aws_ecs_service" "ecs-task-service" {
  launch_type = "FARGATE"
  platform_version = "1.4.0"
  name = "${var.account}-${terraform.workspace}-${var.service}-ecsTaskService"
  cluster = var.ecs-id
  task_definition = aws_ecs_task_definition.ecs-task-definition.arn
  desired_count = var.app_count
  propagate_tags = "TASK_DEFINITION"

  network_configuration {
    security_groups = concat([
      aws_security_group.ecs-task-sg.id], var.additional-service-sg)
    subnets = [
      data.aws_subnet.selected.id]
  }

  load_balancer {
    target_group_arn = var.target-group-arn
    container_name = var.container-image-url
    container_port = var.container-exposed-port[0].port
  }

  tags = {
    Environment = terraform.workspace
    Name  = "${var.account}-${terraform.workspace}-${var.service}-ecsTaskService"
    Account = var.account
    Resource = "ecsTaskService"
    Service = var.service
  }
}
