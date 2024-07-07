variable "subnet-id" {
  description = "Subnet ID"
}

variable "ssl-certificate-arn" {
  description = "SSL certificate ARN"
}

variable "healthcheck-port" {
  description = "Healthcheck port"
  default = 80
}

variable "healthcheck-route" {
  description = "Healthcheck route"
  default = "/"
}

variable "healthcheck-status-code" {
  description = "Status which the ALB will consider to be healthy."
  default = 200
}

variable "stateful" {
  description = "Indicates the ALB whether your service is stateful or not."
  default = false
}

variable "state-cookie-duration"{
  description = "Seconds until the ALB state cookie is renewed. Defaults to 1 day."
  default = 86400
}

variable "cidr_blocks" {
  description = "cidr blocks used in ingress rule for the load balancer"
  default = []
}

variable "securitygroup_ids" {
  description = "security group ids used in ingress rule for the load balancer"
  default = []
}

variable "resource" {
    description = "Name of the resource"
    default = "alb"
}

variable "service" {
  description = "Name of the service deployed"
}

variable "vpc_id" {
  
}

variable "account" {
  
}
