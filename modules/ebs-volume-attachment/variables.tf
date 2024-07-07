variable "service" {
  description = "Volume associated name."
}

variable "environment" {
  description = "Deployment environment"
}

variable "team" {
  description = "devops|dev|data"
  default = "devops"
}

variable "device_name" {
  description = "The device name to expose to the instance (for example, /dev/sdh or xvdh)"
}

variable "volume_id" {
  description = "ID of the Volume to be attached"
}

variable "instance_id" {
  # AWS' optimiced ECS amazon linux 2 based
  description = "ID of the Instance to attach to"
}

variable "skip_destroy" {
  # AWS' optimiced ECS amazon linux 2 based
  description = "Set this to true if you do not wish to detach the volume from the instance to which it is attached at destroy time, and instead just remove the attachment from Terraform state."
  default = true
}


