variable "account"{
}

variable "resource" {
    description = "Name of the resource"
}

variable "service" {
  description = "Name of the service deployed"
}

variable "max_image_count" {
  type        = string
  description = "How many Docker Image versions AWS ECR will store"
  default     = "10"
}

variable "kms_key" {
  type        = string
  description = "KMS ARN to encrypt the images stored by ECR"
  default     = null
}
