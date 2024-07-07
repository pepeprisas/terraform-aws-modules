
variable "region" {
    description="Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
    default = "eu-west-1"
}
variable "name"{
    description="Name with free text to describe the KMS alias name"

}
variable "country"{
    description="Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}
variable "resource" {
    description = "Name of the resource"
    default = "rds-mariadb"
}
variable "team" {
    description = "devops|dev|data"
}

variable "kms_key" {
  description = "ID of the KMS key  used to encryupt the database"
}

variable "availability_zone" {
  default = "eu-west-1a"
}

variable logfiles {
  type = "list"
  default = ["error", "general", "audit"]
}

variable subnet_ids {
}

variable "multi_az" { default = false }

variable "instance_class" {}
variable "allocated_storage" { default = "100"}
variable "database_username" {}
variable "database_password" {}

variable "hostname" {}
variable "vpc_id" {}
variable "route53_zone_id" {}

variable sg_cidr_blocks {
  type = "list"
  default = ["10.8.0.0/16", "10.9.0.0/16"]
}

variable "engine_version" {}
variable "identifier" {}