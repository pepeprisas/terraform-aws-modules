variable "availability_zones" {
  type = "map"
  default = {
    "0" = "eu-west-1a"
    "1" = "eu-west-1b"
    "2" = "eu-west-1c"
  }
}

variable "cidrs" {
  type = "map"
  default = {
    "main" = "172.16.0.0/16"
    "staging" = "172.17.0.0/16"
    "production" = "172.18.0.0/16"
  }
}

variable "cidr_prefixes" {
  type = "map"
  default = {
    "main" = "172"
    "staging" = "172"
    "production" = "172"
  }
}

variable "cidr_blocks" {
  type = "map"
  default = {
    "main" = "16"
    "staging" = "17"
    "production" = "18"
  }
}
