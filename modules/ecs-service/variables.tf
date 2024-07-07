
variable "account"{
  description="account name"
}

variable "subnet-id" {
  description = "Subnet id"
}

variable "ecs-id" {
  description = "ECS cluster Id in which this service will run"
}

variable "target-group-arn" {
  description = "ARN of the target group."
}

variable "additional-service-sg" {
  description = "Additional security group ids to be added to the ECS service"
  default = []
}

variable "container-exposed-port" {
  description = "List of objects that contains a port exposed by the container, the protocol used and cird_blocks if it's needed to use instead of t. As first port-object you should use the app port exposed to the load balancer"
  default = [
    {
      port = 80,
      protocol = "tcp"
      cidr_blocks = null
    }]
}

variable "container-definitions" {
  description = "Array of container definitions that will run in the task."
}

variable "container-image-url" {
  description = "Container image url"
}

variable "alb-sg-id" {
  description = "ALB security group."
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
}

variable "add_volume" {
  type = list(map(string))
  description = "Defines if there is an EFS volume attached. Using the efs id, efs root directory and volume name chose, example: [{efs_if = id, volume_name = name, root_directory = /}]"
  default = []
}

variable "task_role_arn" {
  description = "Task role ARN attached to the ECS task"
}

variable "app_count" {
  description = "Number of task to run in this service"
  default = 1
}

variable "service" {
  description = "Name of the service deployed"
}
