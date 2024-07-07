variable "domains" {
  type = "map"
  default = {
    "0" = "example.com"
    "1" = "example.com"
    "2" = "example.com"
  }
}

variable "domains_by_environment" {
  type = "map"
  default = {
    "main" = "example.com"
    "staging" = "example.com"
    "production" = "example.com"
  }
}

variable "domain_environments" {
  type = "map"
  default = {
    "0" = "production"
    "1" = "staging"
    "2" = "main"
  }
}

variable "main_public_hosted_zone_id" {
  default="Z06370XXXXX"
}

variable "main_private_hosted_zone_id" {
  default="Z06370XXXXX"
}

variable "staging_public_hosted_zone_id" {
  default="Z06370XXXXX"
}
