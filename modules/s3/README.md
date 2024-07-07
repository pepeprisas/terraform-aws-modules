# s3 Module

Create a Simple S3 bucket (only versioning option) and create another S3 with this name-replica in eu-central-1 and configure the replica from the original to the German one.

## Examples

### Bucket with replica, versioning, block public access enabled, default lifecycle and default policy enable

```

module "s3_data_ouput" {
    source = "git::ssh://git@github.com/${var.githubproject}.git//modules/s3"
    region = var.region
    name = var.name
    versioning = var.versioning
    replication = var.replication
    resource = var.resource
    team = var.team
    country = var.country
}
```

### Bucket with replica, versioning, public access and default lifecycle enable

```

module "s3_data_ouput" {
    source                      = "git::ssh://git@github.com/${var.githubproject}.git//modules/s3"
    region                      = var.region
    name                        = var.name
    versioning                  = true
    replication                 = true
    resource                    = var.resource
    team                        = var.team
    country                     = var.country
    block_public_access_enabled = false
    default_policy_enable       = false
}
```

### Bucket without replica, versioning, public access, custom lifecycle and optional tags

```

module "s3_data_ouput" {
    source                      = "git::ssh://git@github.com/${var.githubproject}.git//modules/s3"
    region                      = var.region
    name                        = var.name
    versioning                  = true
    replication                 = false
    resource                    = var.resource
    team                        = var.team
    country                     = var.country
    block_public_access_enabled = false
    default_policy_enable       = false
    tags                        = var.tags
    tags_replica                = var.tags_replica

    lifecycle_rules = [
    {
      id      = "log"
      enabled = true

      prefix = "log/"

      tags = {
        "rule"      = "log"
        "autoclean" = "true"
      }

      transition = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 60
          storage_class = "GLACIER"
        }
      ]

      expiration = {
        days = 90
      }
    }
  ]
}
```
