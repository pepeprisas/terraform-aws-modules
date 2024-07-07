data "aws_caller_identity" "current" {}

resource "aws_iam_role" "replication" {
  count = var.replication && var.versioning ? 1 : 0

  name               = "${var.company}-${var.account}-${terraform.workspace}-${var.name}-replication-s3Role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "s3.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
  tags = {
    Name        = "${var.company}-${var.account}-${terraform.workspace}-${var.name}-replication-s3Role"
    Resource    = "tg"
    Account     = var.account
  }
}

resource "aws_iam_policy" "replication" {
  count = var.replication && var.versioning ? 1 : 0

  name = "${var.company}-${var.account}-${terraform.workspace}-${var.name}-replication-s3Policy"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:GetReplicationConfiguration",
        "s3:ListBucket"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}"
      ]
    },
    {
      "Action": [
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "${aws_s3_bucket.bucket.arn}/*"
      ]
    },
    {
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete"
      ],
      "Effect": "Allow",
      "Resource": "${aws_s3_bucket.bucketdestination[0].arn}/*"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "replication" {
  count = var.replication && var.versioning ? 1 : 0

  role       = aws_iam_role.replication[0].name
  policy_arn = aws_iam_policy.replication[0].arn
}

locals {
  mandatory_tags = {
    Name        = "${var.company}-${var.account}-${terraform.workspace}-s3-${var.name}"
    Resource    = "s3"
    Account     = var.account
  }
  mandatory_replica_tags = {
    Name        = "${var.company}-${var.account}-${terraform.workspace}-s3-${var.name}-replica"
    Resource    = "s3"
    Account     = var.account
  }
}

resource "aws_s3_bucket" "bucket" {

  bucket = "${var.company}-${var.account}-${terraform.workspace}-s3-${var.name}"

  policy = var.policy != "" ? replace(var.policy, "{bucket_name}", "${var.company}-${var.account}-${terraform.workspace}-s3-${var.name}") : null

  acl = "private"

  versioning {
    enabled = var.versioning
  }

  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules
    iterator = rule

    content {
      id                                     = lookup(rule.value, "id", null)
      prefix                                 = lookup(rule.value, "prefix", null)
      tags                                   = lookup(rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = rule.value.enabled

      dynamic "expiration" {
        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [rule.value.expiration]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [rule.value.noncurrent_version_expiration]
        iterator = expiration

        content {
          days = lookup(expiration.value, "days", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transition", [])
        iterator = transition

        content {
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.encryption
      }
    }
  }
  dynamic "replication_configuration" {
    for_each = var.versioning && var.replication ? [var.versioning] : []
    content {

      role = aws_iam_role.replication[0].arn

      rules {
        status = "Enabled"
        id     = "${var.company}-${var.account}-${terraform.workspace}-${var.name}-replication-Rule"
        destination {
          bucket             = aws_s3_bucket.bucketdestination[0].arn
          storage_class      = "GLACIER"
          replica_kms_key_id = "arn:aws:kms:${var.regionreplica}:${data.aws_caller_identity.current.account_id}:alias/aws/s3"

        }
        source_selection_criteria {
          sse_kms_encrypted_objects {
            enabled = true
          }
        }
      }
    }
  }

  tags = merge(local.mandatory_tags, var.tags)

}

resource "aws_s3_bucket" "bucketdestination" {
  count = var.replication && var.versioning ? 1 : 0

  provider = aws.replica
  bucket   = "${var.company}-${var.account}-${terraform.workspace}-s3-${var.name}-replica"
  acl      = "private"

  versioning {
    enabled = var.versioning
  }


  dynamic "lifecycle_rule" {
    for_each = var.lifecycle_rules_replicas
    iterator = rule

    content {
      id                                     = lookup(rule.value, "id", null)
      prefix                                 = lookup(rule.value, "prefix", null)
      tags                                   = lookup(rule.value, "tags", null)
      abort_incomplete_multipart_upload_days = lookup(rule.value, "abort_incomplete_multipart_upload_days", null)
      enabled                                = rule.value.enabled

      dynamic "expiration" {
        for_each = length(keys(lookup(rule.value, "expiration", {}))) == 0 ? [] : [rule.value.expiration]

        content {
          date                         = lookup(expiration.value, "date", null)
          days                         = lookup(expiration.value, "days", null)
          expired_object_delete_marker = lookup(expiration.value, "expired_object_delete_marker", null)
        }
      }

      dynamic "transition" {
        for_each = lookup(rule.value, "transition", [])

        content {
          date          = lookup(transition.value, "date", null)
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }

      dynamic "noncurrent_version_expiration" {
        for_each = length(keys(lookup(rule.value, "noncurrent_version_expiration", {}))) == 0 ? [] : [rule.value.noncurrent_version_expiration]
        iterator = expiration

        content {
          days = lookup(expiration.value, "days", null)
        }
      }

      dynamic "noncurrent_version_transition" {
        for_each = lookup(rule.value, "noncurrent_version_transition", [])
        iterator = transition

        content {
          days          = lookup(transition.value, "days", null)
          storage_class = transition.value.storage_class
        }
      }
    }
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = var.encryption
      }
    }
  }

  tags = merge(local.mandatory_replica_tags, var.tags_replica)

}

resource "aws_s3_bucket_public_access_block" "bucketrestict" {
  count = var.block_public_access_enabled ? 1 : 0

  bucket                  = aws_s3_bucket.bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [var.module_depends_on]
}

resource "aws_s3_bucket_public_access_block" "bucketrestict_replica" {
  count = var.block_public_access_enabled && var.replication && var.versioning ? 1 : 0

  bucket                  = aws_s3_bucket.bucketdestination[0].id
  provider                = aws.replica
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [var.module_depends_on]
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {

  count = var.default_policy_enable ? 1 : 0

  bucket     = aws_s3_bucket.bucket.id
  policy     = data.aws_iam_policy_document.s3_bucket_policy.json
  depends_on = [aws_s3_bucket.bucket, aws_s3_bucket_public_access_block.bucketrestict]
}

resource "aws_s3_bucket_policy" "s3_bucket_policy_bucketdestination" {

  count = var.default_policy_enable && var.replication && var.versioning ? 1 : 0

  provider   = aws.replica
  bucket     = aws_s3_bucket.bucketdestination[0].id
  policy     = data.aws_iam_policy_document.s3_bucket_replica_policy[0].json
  depends_on = [aws_s3_bucket.bucketdestination, aws_s3_bucket_public_access_block.bucketrestict_replica]
}

data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid = "AllowGetFromAccount"
    actions = [
      "s3:Get*",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = [
      "${aws_s3_bucket.bucket.arn}/*",
    ]
  }

  statement {
    sid    = "DenyUnencryptedCommunication"
    effect = "Deny"
    actions = [
      "*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false"
      ]
    }
  }

  statement {
    sid    = "DenyIncorrectEncryptionHeader"
    effect = "Deny"
    actions = [
      "s3:PutObject"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "${var.encryption}"
      ]
    }
  }

  statement {
    sid    = "DenyUnEncryptedObjectUploads"
    effect = "Deny"
    actions = [
      "s3:PutObject"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.bucket.arn}/*"
    ]
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "true"
      ]
    }
  }

}

data "aws_iam_policy_document" "s3_bucket_replica_policy" {
  count = var.replication && var.versioning ? 1 : 0

  statement {
    sid = "AllowGetFromAccount"
    actions = [
      "s3:Get*",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = [
      "${aws_s3_bucket.bucketdestination[0].arn}/*",
    ]
  }

  statement {
    sid    = "DenyUnencryptedCommunication"
    effect = "Deny"
    actions = [
      "*"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.bucketdestination[0].arn}/*"
    ]
    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"

      values = [
        "false"
      ]
    }
  }

  statement {
    sid    = "DenyIncorrectEncryptionHeader"
    effect = "Deny"
    actions = [
      "s3:PutObject"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.bucketdestination[0].arn}/*"
    ]
    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "${var.encryption}"
      ]
    }
  }

  statement {
    sid    = "DenyUnEncryptedObjectUploads"
    effect = "Deny"
    actions = [
      "s3:PutObject"
    ]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
    resources = [
      "${aws_s3_bucket.bucketdestination[0].arn}/*"
    ]
    condition {
      test     = "Null"
      variable = "s3:x-amz-server-side-encryption"

      values = [
        "true"
      ]
    }
  }

}
