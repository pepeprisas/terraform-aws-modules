##########################
###  Main input variables
##########################


variable "environment" {
  description = "Environment"
}

variable "service" {
  description = "Name of the service"
}

variable "team" {
  description = "devops|dev|data"
  default = "devops"
}
variable "container-image-url" {
  description = "Docker image to run in the ECS cluster"
}

variable "subnet-id" {
  description = "Subnet ID"
}

variable "ec2-instance-type" {
  description = "EC2 instance type"
}

variable "task-policy" {
  description = "Task policy bruh"
}

variable "hostname" {
  description = "Application url name"
}

variable "route53_zone_id" {
  description = "Route 53 id where to create a CNAME entry for hostname"
}

variable "extra-user-data" {
  description = "User data to insert into the instances. Keep in mind that the instances are already associated with a cluster"
  default = ""
}

variable "zone-id" {
  description = "Route 53 zone ID"
}

variable "dns-name" {
  description = "DNS record"
}

#################################
### Defaulted input variables
#################################

variable "service-is-stateful" {
  description = "Whether the service is stateful or stateless"
  default = false
}

variable "state-cookie-duration" {
  description = "Seconds until the ALB state cookie is renewed. Defaults to 1 day."
  default = 86400
}

variable "task-cpu" {
  description = "Task cpu"
}

variable "task-memory" {
  description = "Task memory"
}

variable "region" {
  description = "The AWS region to create things in."
  default = "eu-west-1"
}

variable "ec2-ami" {
  description = "AMI used in the ECS EC2 instances"
  default = "ami-04c29bb1e9988c803"
  # AWS' optimiced ECS amazon linux 2 based
}

variable "container-exposed-port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default = 80
}

variable "app_healthcheck_route" {
  description = "Healthcheck route exposed by the app. Healthcheck must return a 200 status code"
  default = "/_health"
}

variable "app_healthcheck_status_code" {
  description = "Healthy status code"
  default = 200
}

variable "app_count" {
  description = "Number of docker containers to run"
  default = 1
}

variable "ssl_certificate_arn" {
  description = "SSL Certificate ARN"
}

variable "additional-service-sg" {
  description = "Array of security groups to add to the task"
}

variable "container-definitions" {
  description = "Array of image definitions"
}

variable "execution-role-policy" {
  description = "Task execution role policy"
}

##########################
### Autoscalling
##########################

variable "cluster-min-size" {
  description = "Minimum cluster size"
  default = 1
}

variable "cluster-starting-size" {
  description = "Starting cluster size"
  default = 1
}

variable "cluster-max-size" {
  description = "Maximum cluster size"
  default = 3
}

variable "cluster-target-cpu" {
  description = "Target cluster average CPU"
  default = 60.0
}

variable "asg-cooldown" {
  description = "Auto scalling group cooldown"
  default = 300
}

variable "asg-instance-warmup" {
  description = "Seconds untill the instance is ready for healthchecks"
  default = 120
}

variable "asg-target-meassurement" {
  description = ""
  default = "ASGAverageCPUUtilization"
}
