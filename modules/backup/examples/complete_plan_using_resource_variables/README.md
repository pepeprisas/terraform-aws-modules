# Complete PLan 

This example shows you how to create a complete plan using multiple resources with variables:

```
locals {
    selection = var.resources_to_backup[var.environment[terraform.workspace]] == null ? [] :[
      for i in var.resources_to_backup[var.environment[terraform.workspace]] : 
      {
        name          = "${i.name}"
        resources     = ["${i.arn}"]
        selection_tag = {}
      }
    ]
}

module "backup" {
  source  = "../../modules/aws-backup"

  email_address = var.email_address

    # Vault
  vault_name = "${var.country}-${var.team}-${var.environment[terraform.workspace]}-${var.service}-main-vault"

  # Plan
  plan_name = "${var.country}-${var.team}-${var.environment[terraform.workspace]}-${var.service}-main-plan"

  # Multiple rules using a list of maps
  rules = [
    {
      name              = "${var.country}-${var.team}-${var.environment[terraform.workspace]}-${var.service}-Rule"
      schedule          = "cron(0 22 ? * * *)"
      target_vault_name = null
      start_window      = 60
      completion_window = 360
      lifecycle = {
        cold_storage_after = var.cold_storage_after[var.environment[terraform.workspace]]
        delete_after       = var.delete_after[var.environment[terraform.workspace]]
      },
      copy_action = {
        lifecycle = {
          cold_storage_after = var.cold_storage_after[var.environment[terraform.workspace]]
          delete_after       = var.delete_after[var.environment[terraform.workspace]]
        },
        destination_vault_arn = "arn:aws:backup:${var.replica_region}:${data.aws_caller_identity.current.account_id}:backup-vault:Default"
      }
      recovery_point_tags = {
        Environment = "${var.environment[terraform.workspace]}"
      }
    },
  ]

  # Multiple selections
  selections = local.selection

  tags = {
    Name        = "${var.country}-${var.team}-${var.environment[terraform.workspace]}-${var.service}-${var.function_name}"
    Country     = var.country
    Service     = var.service
    Environment = var.environment[terraform.workspace]
    Team        = var.team
  }
}
```

