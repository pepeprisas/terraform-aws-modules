variable "region" {
  default = "eu-west-1"
  description = "The region where will be deployed"
}

variable "country" {
  description="Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}


variable "team" {
  description = "devops|dev|data"
}

variable "environment" {
  description = "The resource that will be passed with terraform.workspace variable from resource"
}

variable "resource" {
  description = "Name of the resource"
}

variable "image" {
  description = "Name of the docker image"
}

variable "service" {
  description = "Name of the service deployed"
}

variable "freetext"{
  description="freetext to explain the resource"
  default = null
}
