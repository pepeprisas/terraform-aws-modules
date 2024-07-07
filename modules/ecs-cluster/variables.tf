variable "region" {
  description = "The AWS region to create things in."
  default     = "eu-west-1"
}

variable "account"{
  description="Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}

variable "resource" {
  description = "AWS resource name"
  default = "ecsCluster"
}

variable "service" {
  description = "Name of the service deployed"
}