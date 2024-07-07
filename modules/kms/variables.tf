variable "alias_name" {
  description = "The name of the key alias"
  type        = string
}

variable "deletion_window_in_days" {
  description = "The duration in days after which the key is deleted after destruction of the resource"
  type        = string
  default     = 30
}

variable "description" {
  description = "The description of this KMS key"
  type        = string
}

variable "iam_policy" {
  description = "The policy of the key usage"
  type        = string
  default     = null
}

variable "is_enabled" {
  description = "(Optional) Specifies whether the key is enabled. Defaults to true."
  type        = bool
  default     = true
}

variable "enable_key_rotation" {
  description = "(Optional) Specifies whether key rotation is enabled. Defaults to false."
  type        = bool
  default     = true
}

variable "account"{
    description="account name of where is the resource is deployed"
}
variable "team" {
    description = "devops|dev|data"
}

variable "service" {
  description = "Name of the service deployed"
}

