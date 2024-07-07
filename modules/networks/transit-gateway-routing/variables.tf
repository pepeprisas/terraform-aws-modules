variable "environment_cidr" {}
variable "main_cidr" {}
variable "tgw_id" {}

variable "main_private_route_tables" {
  type = "list"
  default = []
}

variable "main_public_route_table" {}
variable "public_route_table" {}
variable "route_tables_count" {}

variable "private_route_tables" {
  type = "list"
  default = []
}
