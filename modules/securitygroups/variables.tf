variable "region" {
  description = "Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
  default     = "eu-west-1"
}
variable "name" {
  description = "Name with free text to describe the s3 name"
}
variable "description" {
  description = "choose true for versioning the bucket or false"
}
variable "country" {
  description = "Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}
variable "resource" {
  description = "Name of the resource"
}
variable "team" {
  description = "devops|dev|data"
}

variable "service" {
  description = "Name of the service deployed"
}

variable "freetext" {
  description = "freetext to explain the resource"
  default     = null
}

variable "vpc_id" {
  description = "VPC identifier"
}

variable "revoke_rules_on_delete" {
  description = "Instruct Terraform to revoke all of the Security Groups attached ingress and egress rules before deleting the rule itself. Enable for EMR."
  type        = bool
  default     = false
}

variable "ingress_with_cidr_blocks" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))
  default = []
}

variable "egress_with_cidr_blocks" {
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_block  = string
    description = string
  }))
  default = []
}
variable "autoremove" {
  description = "Tag to avoid deleting a security group that is required but has no network interface or other security group permanently attached to it. True|False"
}