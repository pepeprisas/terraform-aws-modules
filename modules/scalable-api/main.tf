data "aws_subnet" "selected" {
  id = var.subnet-id
}

#module "alb" {
#  source = "../alb"
#  account = var.account
#  service = var.service
#  environment = var.environment
#  subnet-id = var.subnet-id
#  ssl-certificate-arn = var.ssl_certificate_arn
#  team = var.team
#  healthcheck-route = var.app_healthcheck_route
#  healthcheck-status-code = var.app_healthcheck_status_code
#  stateful = var.service-is-stateful
#  state-cookie-duration = var.state-cookie-duration
#}

module "asg" {
  source = "../asg"
  service = var.service
  environment = var.environment
  subnet-id = var.subnet-id
  alb-arn = module.alb.arn
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

resource "aws_route53_record" "cname_route53_record" {
  zone_id = var.zone-id
  name = var.service
  type = "CNAME"
  ttl = "60"
  records = [var.dns-name]
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
#  target-group-arn = module.alb.target-group-arn
#  additional-service-sg = var.additional-service-sg
#  container-exposed-port = var.container-exposed-port
#  container-definitions = var.container-definitions
#  container-image-url = var.container-image-url
#  alb-sg-id = module.alb.alb-sg-id
#  task-role-policy = var.task-policy
#  execution-role-policy = var.execution-role-policy
#}
