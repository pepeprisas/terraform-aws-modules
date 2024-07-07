variable "service" {
  description = "SQS associated name."
}

variable "environment" {
  description = "Deployment environment"
}

variable "team" {
  description = "devops|dev|data"
  default = "devops"
}

variable "redrive_policy" {
  description = "Redrive policy object. It's mandatory jsonencode built-in function."
  default = 0
}

variable "max_message_size" {
  description = "Limit of how many bytes a message can contain before SQS rejects it."
  default = 262144
}

variable "message_retention_seconds" {
  # AWS' optimized ECS amazon linux 2 based
  description = "Number of seconds Amazon SQS retains a message."
  default = 1209600
}

variable "policy" {
  # AWS' optimized ECS amazon linux 2 based
  description = "Policy for SQS"
}

variable "fifo_queue" {
  description = "Fifo queue enabled"
  default = false
}

variable "content_based_deduplication" {
  description = "Enables content-based deduplication for FIFO queues."
  default = false
}

variable "kms_master_key_id" {
  description = "The ID of an AWS-managed customer master key for SQS or a custom CMK."
  default = null
}

variable "kms_data_key_reuse_period_seconds" {
  description = "The length of time, in seconds, for which SQS can reuse a data key to encrypt or decrypt messages before calling KMS again."
  default = 300
}

