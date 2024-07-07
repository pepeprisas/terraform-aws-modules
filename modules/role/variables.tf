variable "rolename" {
  description = "Name of the role"
  default = "testmanuborramerole"
}
variable "policy"{
  description="Policy document in json format"
}
variable "assumepolicy" {
  description = "Policy with assume role"
}
variable "account"{
}

variable "service" {
  description = "Name of the service deployed"
}

variable "resource" {
  description = "Name of the resource"
  default = "role"
}
variable "freetext"{
    description="freetext to explain the resource"
}
