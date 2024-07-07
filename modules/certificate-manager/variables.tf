variable "country" {
  description = "Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}

variable "team" {
  description = "devops|dev|data"
}

variable "private_zone" {
  description = "Select if is a private route53 zone. Most of the times will be public (false)"
}

variable "domain_name" {
  description = "Domain name"
}

variable "zone_name" {
  description = "Route53 zone name"
}

variable "freetext" {
  description = "Freetext to explain the certificate resource"
}
