variable "region" {
  default = "eu-west-1"
}

variable "country"{
    description="Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}
variable "team" {
    description = "devops|dev|data"
}

variable "service" {
  description = "Name of the service deployed"
}

variable "freetext"{
    description = "freetext to explain the resource"
}

variable "function"{
    description = "directory under ./scripts to identify lambda code" 
    // ./scripts/<function>/index.py
}

variable "vpcs" {
  description = "VPC config block for the lambda if it needed"
  default = []
}
