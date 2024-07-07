variable "domains" {
  type="map"
  default={}
}

variable "environments" {
  type="map"
  default={}
}

variable "region" {
  default = "eu-west-1"
}

variable "role" {
  default = "domain"
}

variable "service" {
  default = "certificate"
}
