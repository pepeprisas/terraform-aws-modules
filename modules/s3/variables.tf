variable "region" {
  description = "Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
  default     = "eu-west-1"
}
variable "regionreplica" {
  description = "Region where the S3 replica"
  default     = "eu-central-1"
}
variable "name" {
  description = "Name to describe the s3 bucket name"
}
variable "versioning" {
  description = "choose true for versioning the bucket or false"
  default     = true
}
variable "replication" {
  description = "choose true to create a replication of the bucket or false"
  default     = true
}
variable "company" {
  description = "Company acronym"
}
variable "encryption" {
  description = "Define which kind of encryption is neeeded for the S3 bucket and replica resource to be created"
  default     = "AES256"
}
variable "lifecycle_rules" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default = [
    {
      id      = "s3-lifecycle-rule"
      enabled = true

      tags = {
        "rule"      = "default-rules"
        "autoclean" = "true"
      }

      expiration = {
        days = 1825
      }

      noncurrent_version_transition = [
        {
          days          = 90
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_expiration = {
        days = 365
      }
    }
  ]
}
variable "lifecycle_rules_replicas" {
  description = "List of maps containing configuration of object lifecycle management."
  type        = any
  default = [
    {
      id      = "s3-lifecycle-rule-replica"
      enabled = true

      tags = {
        "rule"      = "default-rules-replica"
        "autoclean" = "true"
      }

      transition = [
        {
          days          = 1
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 90
      }

      noncurrent_version_transition = [
        {
          days          = 1
          storage_class = "GLACIER"
        }
      ]

      noncurrent_version_expiration = {
        days = 90
      }
    }
  ]
}
variable "block_public_access_enabled" {
  type        = bool
  description = "(optional) Whether to create block_public_access_enabled or not. Default is true."
  default     = true
}

variable "default_policy_enable" {
  type        = bool
  description = "(optional) Whether to create default policy for buckets or not. Default is true."
  default     = true
}

variable "module_depends_on" {
  type        = any
  description = "(optional) A list of external resources the module depends_on. Default is []."
  default     = []
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the bucket."
  default     = {}
}
variable "tags_replica" {
  description = "(Optional) A mapping of tags to assign to the bucket replica."
  default     = {}
}
variable "account" {
}

variable "policy" {
  default = ""
}
