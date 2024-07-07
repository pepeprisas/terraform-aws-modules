## Create RDS Postgresql 

This example to create database Popstgresql

### Example

Include in your main.tf file:  
```
# Declare the data source
data "aws_availability_zones" "available" {
  state = "available"
}

module "rds" {
  source = "git::ssh://git@github.com/${var.githubproject}.git//modules/rds-postgresql?ref=v1.1.0"
  country = var.country
  team = var.team
  instance_class = "db.m5.large"
  allocated_storage = 200
  database_name = var.name
  name = var.name
  database_username = "devops"
  database_password = "willbechanged"
  multi_az = false
  availability_zone = data.aws_availability_zones.available.names[0]
  hostname = "${var.name}${var.db_hostname[terraform.workspace]}"
  engine_version = "12.4"
  subnet_ids = data.terraform_remote_state.environment_networking.outputs.private_subnet_ids
  vpc_id  = data.terraform_remote_state.environment_networking.outputs.vpc_id
  route53_zone_id = data.terraform_remote_state.environment_dns.outputs.private_hosted_zone_id
  sg_cidr_blocks = ["10.9.0.0/16", lookup(module.aws_networking_mappings.cidrs, terraform.workspace)]
  kms_key = "arn:aws:kms:eu-west-1:123456789012:key/12c456b8-12c4-56b8-012c-12c456b89012" # aws/rds KMS
  environment = terraform.workspace
  region = var.region
}


```

  
Pass the rest of the variables needed in your `variable.tf` file. For example:  
```
variable "name"{
  description="Name of the cluster"
}
variable "country"{
  description="Country code https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes"
}
variable "team" {
  description = "devops|dev|data"
}

variable "access_point_list" {
  description = "List of maps with the access point parameters."
}
```