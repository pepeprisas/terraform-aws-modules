# AWS Backup vault
resource "aws_backup_vault" "ab_vault" {
  count       = var.enabled && var.vault_name != null ? 1 : 0
  name        = var.vault_name
  kms_key_arn = var.vault_kms_key_arn
  tags        = var.tags
}

resource "aws_sns_topic" "backupSNSTopic" {
  count = var.enabled && var.vault_name != null ? 1 : 0
  name  = "${var.vault_name}-backupVaultEvents"
  tags  = var.tags
}

data "aws_iam_policy_document" "backupIAMPolicy" {
  count       = var.enabled && var.vault_name != null ? 1 : 0
  policy_id = "__default_policy_ID"

  statement {
    actions = [
      "SNS:Publish",
    ]

    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["backup.amazonaws.com"]
    }

    resources = [
      aws_cloudformation_stack.sns-topic[count.index].outputs.ARN
    ]

    sid = "__default_statement_ID"
  }
}

resource "aws_sns_topic_policy" "backupTopicPolicy" {
  count  = var.enabled && var.vault_name != null ? 1 : 0
  arn    = aws_cloudformation_stack.sns-topic[count.index].outputs.ARN
  policy = data.aws_iam_policy_document.backupIAMPolicy[count.index].json
}

resource "aws_backup_vault_notifications" "backupVaultNotifications" {
  count  = var.enabled && var.vault_name != null ? 1 : 0
  backup_vault_name   = aws_backup_vault.ab_vault[count.index].name
  sns_topic_arn       = aws_cloudformation_stack.sns-topic[count.index].outputs.ARN
  backup_vault_events = ["BACKUP_JOB_FAILED","BACKUP_JOB_EXPIRED","RESTORE_JOB_COMPLETED","RESTORE_JOB_SUCCESSFUL","RESTORE_JOB_FAILED","COPY_JOB_FAILED"] # "BACKUP_JOB_STARTED","BACKUP_JOB_COMPLETED","BACKUP_JOB_SUCCESSFUL","BACKUP_JOB_FAILED","BACKUP_JOB_EXPIRED","RESTORE_JOB_STARTED","RESTORE_JOB_COMPLETED","RESTORE_JOB_SUCCESSFUL","RESTORE_JOB_FAILED","COPY_JOB_STARTED","COPY_JOB_SUCCESSFUL","COPY_JOB_FAILED","RECOVERY_POINT_MODIFIED","BACKUP_PLAN_CREATED","BACKUP_PLAN_MODIFIED"
}


data "template_file" "cloudformation_sns_stack" {
  count       = var.enabled && var.vault_name != null ? 1 : 0
  template = file("${path.module}/templates/email-sns-stack.json.tpl")

  vars = {
    display_name  = "${aws_backup_vault.ab_vault[count.index].name}-${var.display_name}"
    email_address = var.email_address
    protocol      = var.protocol
  }
}

resource "aws_cloudformation_stack" "sns-topic" {
  count       = var.enabled && var.vault_name != null ? 1 : 0

  name          = "${aws_backup_vault.ab_vault[count.index].name}-${var.stack_name}"
  template_body = data.template_file.cloudformation_sns_stack[count.index].rendered

  tags = merge(
    var.additional_tags,
    {
      "Name" = var.stack_name
    },
  )
}


# AWS Backup plan
resource "aws_backup_plan" "ab_plan" {
  count = var.enabled ? 1 : 0
  name  = var.plan_name

  # Rules
  dynamic "rule" {
    for_each = local.rules
    content {
      rule_name           = lookup(rule.value, "name", null)
      target_vault_name   = lookup(rule.value, "target_vault_name", null) == null ? var.vault_name : lookup(rule.value, "target_vault_name", "Default")
      schedule            = lookup(rule.value, "schedule", null)
      start_window        = lookup(rule.value, "start_window", null)
      completion_window   = lookup(rule.value, "completion_window", null)
      recovery_point_tags = length(lookup(rule.value, "recovery_point_tags")) == 0 ? var.tags : lookup(rule.value, "recovery_point_tags")

      # Lifecycle  
      dynamic "lifecycle" {
        for_each = length(lookup(rule.value, "lifecycle")) == 0 ? [] : [lookup(rule.value, "lifecycle", {})]
        content {
          cold_storage_after = lookup(lifecycle.value, "cold_storage_after", 0)
          delete_after       = lookup(lifecycle.value, "delete_after", 90)
        }
      }

      # Copy action
      dynamic "copy_action" {
        for_each = length(lookup(rule.value, "copy_action", {})) == 0 ? [] : [lookup(rule.value, "copy_action", {})]
        content {
          destination_vault_arn = lookup(copy_action.value, "destination_vault_arn", null)

          # Copy Action Lifecycle
          dynamic "lifecycle" {
            for_each = length(lookup(copy_action.value, "lifecycle", {})) == 0 ? [] : [lookup(copy_action.value, "lifecycle", {})]
            content {
              cold_storage_after = lookup(lifecycle.value, "cold_storage_after", 0)
              delete_after       = lookup(lifecycle.value, "delete_after", 90)
            }
          }
        }
      }

    }
  }


  # Tags
  tags  = {
    Environment = terraform.workspace
    Name  = "${var.plan_name}-backupPlan"
    Country = var.country
    Resource = "backupPlan"
    Environment = terraform.workspace
    Team = var.team
    Service = var.service
  }

  # First create the vault if needed
  depends_on = [aws_backup_vault.ab_vault]
}

locals {

  # Rule
  rule = var.rule_name == null ? [] : [
    {
      name              = var.rule_name
      target_vault_name = var.vault_name != null ? var.vault_name : "Default"
      schedule          = var.rule_schedule
      start_window      = var.rule_start_window
      completion_window = var.rule_completion_window
      lifecycle = var.rule_lifecycle_cold_storage_after == null ? {} : {
        cold_storage_after = var.rule_lifecycle_cold_storage_after
        delete_after       = var.rule_lifecycle_delete_after
      }
      recovery_point_tags = var.rule_recovery_point_tags
    }
  ]

  # Rules
  rules = concat(local.rule, var.rules)

}
