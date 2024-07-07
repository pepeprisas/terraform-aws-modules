variable "vpc_id" {}

variable "vpc_cidr_prefix" {
  default="172"
}

variable "vpc_cidr_block" {
  default="16"
}

variable "vpc_cidr_3AZ_public" {
  type = "map"
  default = {
    "0" = "0.0/19"
    "1" = "32.0/19"
    "2" = "64.0/19"
  }
}

variable "vpc_cidr_3AZ_private" {
  type = "map"
  default = {
    "0" = "96.0/19"
    "1" = "128.64/19"
    "2" = "160.128/19"
  }
}

variable "availability_zones" {
  type = "map"
  default = {}
}

variable "region" {
  default = "eu-west-1"
}

variable "environment" {
  default = "production"
}

variable "role" {
  default = "subnet"
}

variable "service" {
  default = "vpc"
}
