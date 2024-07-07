
variable "account"{
}

variable "subnet_ids" {
  description = "Subnet id"
}

variable "efs_security_group" {
  description = "Security group for access to EFS"
}

variable "service" {
  description = "Name of the service deployed"
}