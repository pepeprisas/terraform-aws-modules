## AWS ElasticSearch Service Module deployment with terraform

Deploying [ES service](https://docs.aws.amazon.com/elasticsearch-service/latest/developerguide/what-is-amazon-elasticsearch-service.html) (ElasticSearch Service) with [Terraform](https://www.terraform.io/) version >= 0.12


## Configuration
To create a new project sourcing from this module you have to specify in your project `main.tf` file the following data:  
```
provider "aws" {
  region        = "eu-west-1"
}

module "elasticsearch" {
  source                = "git::ssh://git@github.com/${var.githubproject}.git//modules/elasticsearch"
  service               = var.service
  team                  = var.team
  country               = var.country
  domain_name           = var.domain_name
  vpc_id                = var.vpc_id
  subnet_ids            = var.subnet_ids
  cidr_blocks           = var.cidr_blocks
  route53_zone_id       = var.route53_zone_id
  es_version            = var_es.version
  kms_id                = var.kms_id
}
```

After this, create in the `variables.tf` file in your project with the needed variables:  
```
variable "region" {
  default	= "eu-west-1"
}

variable "service" {
  default	= "..."
}

variable "country" {
  default	= "..."
}

variable "team" {
  default	= "..."
}

variable "domain_name" {
  default       = "..."
}

variable "vpc_id" {
  description   = "Existing VPC"
  default       = "vpc-..."
}

variable "subnet_ids" {
  description	= "Existing private subnets for VPC"
  type		= list(string)
  default	= ["subnet-...", "subnet-..."]
}

variable "cidr_blocks" {
  description   = "List of CIDR blocks for open 443 in Security group"
  type          = list(string)
  default       = ["...", "...", "..."]
}

variable "route53_zone_id" {
  description	= "Route53 Hosted zone ID"
  default	= "..."
}

variable "es_version" {
  default       = "..."
}

variable "kms_id" {
  default       = "..."
}
```
