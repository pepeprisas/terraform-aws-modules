variable "service" {
  description = "ASG associated name."
}

variable "environment" {
  description = "Deployment environment"
}


variable "instance-type" {
  description = "EC2 instance type"
}

variable "subnet-id" {
  description = "Subnet Id"
}

variable "alb-arn" {
  description = "ALB ARN"
}

variable "user-data" {
  description = "Instance user data"
}

variable "team" {
  description = "devops|dev|data"
  default = "devops"
}

variable "ec2-ami" {
  # AWS' optimiced ECS amazon linux 2 based
  description = "AMI used in the ECS EC2 instances"
  default = "ami-04c29bb1e9988c803"
}

variable "min-size" {
  description = "Minimum cluster size"
  default = 1
}

variable "starting-size" {
  description = "Starting cluster size"
  default = 1
}

variable "max-size" {
  description = "Maximum cluster size"
  default = 3
}

variable "target-meassurement" {
  description = "Meassurement to track to trigger a scale in/out action"
  default = "ASGAverageCPUUtilization"
}

variable "target-value" {
  description = "Target cluster average CPU"
  default = 60.0
}

variable "cooldown" {
  description = "Auto scalling group cooldown"
  default = 300
}

variable "instance-warmup" {
  description = "Seconds untill the instance is ready for healthchecks"
  default = 120
}

variable health-check-type {
  description = "The service to use for the health checks. The valid values are EC2 and ELB."
  default = "ELB"
}
