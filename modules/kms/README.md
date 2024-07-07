
# Terraform AWS KMS

Terraform module to deploy a KMS key. Currently, this module creates a single encryption key that is used for both encrypt and decrypt operations with KMS as origin.

## Usage example


```hcl
module kms {
  source = "git::ssh://git@github.com/${var.githubproject}.git//modules/kms"

  alias_name              = "parameter_store_key"
  description             = "Key to encrypt and decrypt secrets"

  # Tags
  tags = {
    Name        = "uk-devops-production-kms-cloudwatchLogs"
    Country     = "uk"
    Team        = "devops"
    Environment = "production"
    Service     = "kms"
    ...
  }
}
```


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| alias\_name | The name of the key alias | string | n/a | yes |
| deletion\_window\_in\_days | The duration in days after which the key is deleted after destruction of the resource | string | `"30"` | no |
| description | The description of this KMS key | string | n/a | yes |
| enable\_key\_rotation | \(Optional\) Specifies whether key rotation is enabled. Defaults to false. | bool | `"true"` | no |
| iam\_policy | The policy of the key usage | string | `"null"` | no |
| is\_enabled | \(Optional\) Specifies whether the key is enabled. Defaults to true. | bool | `"true"` | no |
| tags | \(Optional\) A mapping of tags to assign to the object. | map | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| key\_alias\_arn | The Amazon Resource Name \(ARN\) of the key alias |
| key\_alias\_name | The display name of the alias. |
| key\_arn | The Amazon Resource Name \(ARN\) of the key. |
| key\_id | The globally unique identifier for the key. |

## TO DO

- Add support to define key administrators
- Add suport to define key users
- Add support to enable from other AWS accounts
- Add support for asymmetric keys
- Add support for external and Custom key store
