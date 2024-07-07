module "aws_backup_example" {

  source = "git::ssh://git@github.com/${var.githubproject}.git//modules/backup"

  # Email for notifications
  email_address = "${var.email_address}"

  # Vault
  vault_name = "vault-0"

  # Plan
  plan_name = "simple-plan"

  # One rule
  rule_name                         = "rule-1"
  rule_schedule                     = "cron(0 12 * * ? *)"
  rule_start_window                 = 120
  rule_completion_window            = 360
  rule_lifecycle_cold_storage_after = 30
  rule_lifecycle_delete_after       = 120

  # One selection
  selection_name      = "selection-1"
  selection_resources = ["arn:aws:dynamodb:us-east-1:123456789101:table/mydynamodb-table"]
  
  # Tags
  tags = {
    Name        = "${var.country}-${var.team}-${var.environment[terraform.workspace]}-${var.service}-${var.function_name}"
    Country     = var.country
    Service     = var.service
    Environment = var.environment[terraform.workspace]
    Team        = var.team
  }
}
