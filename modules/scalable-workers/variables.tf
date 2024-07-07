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

variable "subnet-id" {
  description = "Subnet ID"
}

variable "ec2-instance-type" {
  description = "EC2 instance type"
}

variable "task-policy" {
  description = "Task policy bruh"
}

variable "extra-user-data" {
  description = "User data to insert into the instances. Keep in mind that the instances are already associated with a cluster"
  default = ""
}

variable "ec2-ami" {
  description = "AMI used in the ECS EC2 instances"
  default = "ami-04c29bb1e9988c803"
  # AWS' optimiced ECS amazon linux 2 based
}

variable "additional-service-sg" {
  description = "Array of security groups to add to the task"
}

variable "container-definitions" {
  description = "Array of container definitions. In order to add a healthcheck to the container a key healthCheck has to be added to container definitions with value like { command: [ CMD-SHELL, curl -f http://localhost:80 || exit 1 ], startPeriod: 20 } assuming there is a healthcheck daemon listening on port 80. For default values read more at https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task_definition_parameters.html#container_definition_healthcheck"
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