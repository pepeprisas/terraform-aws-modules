variable "vpc_id" {}

variable "region" {
  default = "eu-west-1"
}

variable "environment" {
  default = "production"
}

variable "role" {
  default = "routes"
}

variable "service" {
  default = "vpc"
}

variable "private_subnet_ids" {
  type = "list"
  default = []
}

variable "public_subnet_ids" {
  type = "list"
  default = []
}

variable "items" {
  default = 0
}
