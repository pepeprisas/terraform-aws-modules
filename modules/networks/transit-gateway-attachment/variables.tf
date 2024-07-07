variable "vpc_id" {}
variable "cidr" {}
variable "main_vpc_id" {}
variable "main_cidr" {}
variable "transit_gw_id" {}

variable "region" {
  default = "eu-west-1"
}

variable "environment" {
  default = "production"
}

variable "role" {
  default = "attachment"
}

variable "service" {
  default = "transit"
}

variable "subnet_ids" {
  type = "list"
  default = []
}

variable "main_subnet_ids" {
  type = "list"
  default = []
}