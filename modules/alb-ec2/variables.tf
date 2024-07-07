variable "region" {
}
variable "account" {
  description = "account"
}
variable "team" {
  description = "devops|dev|data"
}
variable "subnet_id" {
  description = "Subnet in the vpc"
}
variable "sgid" {
  description = "segurity group id for ec2"
}
variable "ec2id" {
  description = "ec2 id"
}
variable "port" {
  description = "alb port"
}

variable "service" {
  description = "Name of the service deployed"
}
