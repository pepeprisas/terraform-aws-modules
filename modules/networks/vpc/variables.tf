variable "cidr_block" {}

variable "region" {
  default = "eu-west-1"
}

variable "environment" {
  default = "production"
}

variable "role" {
  default = "main"
}

variable "service" {
  default = "vpc"
}
