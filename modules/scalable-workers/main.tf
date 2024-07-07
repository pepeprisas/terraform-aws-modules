data "aws_subnet" "selected" {
  id = var.subnet-id
}

module "asg" {
  source = "../asg"
  service = var.service
  environment = var.environment
  subnet-id = var.subnet-id
  alb-arn = null
  team = var.team
  ec2-ami = var.ec2-ami
  min-size = var.cluster-min-size
  max-size = var.cluster-max-size
  starting-size = var.cluster-starting-size
  target-meassurement = var.asg-target-meassurement
  target-value = var.cluster-target-cpu
  cooldown = var.asg-cooldown
  instance-warmup = var.asg-instance-warmup
  instance-type = var.ec2-instance-type
  health-check-type = "EC2"
  user-data = <<-EOT
#cloud-boothook
#!/bin/bash
echo ECS_CLUSTER=${module.cluster.name} >> /etc/ecs/ecs.config
sudo sed -i 's/{cluster}/${module.cluster.name}/g' /etc/awslogs/awslogs.conf
sudo sed -i 's/{container_instance_id}/'$(curl http://169.254.169.254/latest/meta-data/instance-id)'/g' /etc/awslogs/awslogs.conf
sudo service awslogs start
${var.extra-user-data}
EOT
}

module "log-group" {
  source = "../log-group"
  service = var.service
  environment = var.environment
  team = var.team
}

#module "cluster" {
#  source = "../ecs-cluster"
#  service = var.service
#  environment = var.environment
#  team = var.team
#}

#module "task" {
#  source = "../ecs-service"
#  service = var.service
#  environment = var.environment
#  subnet-id = var.subnet-id
#  ecs-id = module.cluster.id
#  target-group-arn = null
#  additional-service-sg = var.additional-service-sg
#  container-exposed-port = null
#  container-definitions = var.container-definitions
#  container-image-url = null
#  alb-sg-id = null
#  task-role-policy = var.task-policy
#  execution-role-policy = var.execution-role-policy
#}
