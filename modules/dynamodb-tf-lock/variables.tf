variable "region" {
  default = "eu-west-1"
}

variable "country" {
  default = "uk"
}

variable "team" {
  default = "devops"
}

variable "resource" {
  default = "dynamodb"
}

variable "hash" {
  default = "LockID"
}

variable "service" {
  description = "Name of the service deployed"
  default = "terraform-lock"
}
