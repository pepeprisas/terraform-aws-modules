variable "domain" {}

variable "environment" {
}

variable "vpc_id" {}

variable "region" {
  default = "eu-west-1"
}

variable "role" {
  default = "private"
}

variable "service" {
  default = "hosted-zone"
}
