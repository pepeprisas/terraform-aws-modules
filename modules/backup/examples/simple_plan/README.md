# Simple plan using lists

This example shows you how to create a simple plan using lists instead of variables:

```
module "aws_backup_example" {
  
  source = "git::ssh://git@github.com/${var.githubproject}.git//modules/backup"

  # Email for notifications
  email_address = "${var.email_address}"

  # Vault
  vault_name = "vault-1"

  # Plan
  plan_name = "simple-plan-list"

  # One rule using a list of maps
  rules = [
    {
      name              = "rule-1"
      schedule          = "cron(0 12 * * ? *)"
      start_window      = 120
      completion_window = 360
      lifecycle = {
        cold_storage_after = 0
        delete_after       = 90
      },
      recovery_point_tags = {
      Environment = var.environment[terraform.workspace]
      }
    },
  ]

  # One selection using a list of maps
  selections = [
    {
      name      = "selection-1"
      resources = ["arn:aws:dynamodb:us-east-1:123456789101:table/mydynamodb-table1"]
      selection_tag = {
        type  = "STRINGEQUALS"
        key   = "Environment"
        Environment = var.environment[terraform.workspace]
      }
    },
    {
      name      = "selection-2"
      resources = ["arn:aws:dynamodb:us-east-1:123456789101:table/mydynamodb-table2"]
    },
  ]

  tags = {
    Name        = "${var.country}-${var.team}-${var.environment[terraform.workspace]}-${var.service}-${var.function_name}"
    Country     = var.country
    Service     = var.service
    Environment = var.environment[terraform.workspace]
    Team        = var.team
  }
}
```
