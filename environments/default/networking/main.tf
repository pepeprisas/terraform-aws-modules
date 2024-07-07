variable "region" { default = "eu-west-1" }
variable "environment" { default = "default" }

provider "aws" { region = "${var.region}" }

terraform {
  backend "s3" {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/default-networking-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    acl     = "bucket-owner-full-control"
  }
}

module "aws_networking_mappings" {
  source  = "../../../mappings/networks"
}

module "transit_gateway" {
  source  = "../../../modules/networks/transit-gateway"
  environment = "${var.environment}"
  region = "${var.region}"
}
