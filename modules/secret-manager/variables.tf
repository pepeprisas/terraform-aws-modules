variable "region" {
  description = "Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
  default     = "eu-west-1"
}
variable "name" {
  description = "free texto to describe kind of secret"
}
variable "account" {
}
variable "secretmap" {
  default = {
    key1 = "user"
    key2 = "passw"
  }
  type = map(string)
}

variable "service" {
  description = "Name of the service deployed"
}

variable "freetext"{
  description="freetext to explain the resource"
  default = null
}