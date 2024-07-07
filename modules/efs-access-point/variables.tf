
variable "country"{
  description="Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}
variable "team" {
  description = "devops|dev|data"
}

variable "access_point_list" {
  description = "List of maps with the access point parameters."
}

variable "service" {
  description = "Name of the service deployed"
}