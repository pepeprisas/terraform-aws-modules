# sns-email Module

This module creates a sns topic send emails.

## Examples

### Bucket with replica, versioning, block public access enabled, default lifecycle and default policy enable

```
module "SnsTopic" {
  source = "git::ssh://git@github.com/${var.githubproject}.git//modules/sns-email"

  display_name  = "event-rule-action"
  email_address = "cloudarchitectureandsecurity@example.com"
  stack_name    = "${var.country}-${var.team}-${var.environment[terraform.workspace]}-${var.service}-securityGroupsInventory"
}

```
