resource "aws_sqs_queue" "sqs" {
  name                      = "${var.service}-${var.environment}-sqs-queue"
  delay_seconds             = 0
  max_message_size          = var.max_message_size
  message_retention_seconds = var.message_retention_seconds
  policy                    = var.policy
  redrive_policy            = var.redrive_policy

  fifo_queue = var.fifo_queue
  content_based_deduplication = var.fifo_queue == true ? var.content_based_deduplication : null

  kms_master_key_id                 = var.kms_master_key_id
  kms_data_key_reuse_period_seconds = var.kms_master_key_id ? var.kms_data_key_reuse_period_seconds : null

  tags = {
    Name = "${var.service}-${var.environment}-sqs"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}


