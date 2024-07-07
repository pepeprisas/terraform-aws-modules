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

variable "az" {
  description = "The AZ where the EBS volume will exist i.e: us-west-2a"
}

variable "size" {
  description = "The size of the drive in GiBs."
}

variable "iops" {
  # AWS' optimiced ECS amazon linux 2 based
  description = "The amount of IOPS to provision for the disk. "
  default = 3000
}


