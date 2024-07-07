variable "region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "environment" {
  description = "Environment"
  default     = "staging"
}

variable "role" {
  description = "Role"
  default     = "proxy"
}

variable "service" {
  description = "Service"
  default     = "notification"
}

variable "vpc_id" {
  description = "VPC id"
}

variable "subnet_ids" {
  description = "Subnet IDs"
}

variable "vpc_cidr" {
  description = "VPC cidr"
}

variable "notification_endpoint" {
  description = "HTTP endpoint to forward sns topic messages"
}