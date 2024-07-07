variable "region" {
  default = "eu-west-1"
}
variable "environment" {
  default = "main"
}
variable "role" {
  default = "new"
}
variable "service" {
  default = "vpn"
}
variable "instance_type" {
  default = "t2.micro"
}
variable "storage_size" {
  default = "10"
}

variable "hostname" {
  default = "vpnc.example.com"
}

variable "vpn_cidr" {
  default = "10.9.0.0/24"
}