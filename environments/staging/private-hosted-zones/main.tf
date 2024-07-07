provider "aws" { region = "${var.region}" }

terraform {
  backend "s3" {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/staging-private-hosted-zones-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    acl     = "bucket-owner-full-control"
  }
}

module "aws_dns_mappings" {
  source  = "../../../mappings/dns"
}

data "terraform_remote_state" "staging_networking" {
  backend = "s3"
  config = {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/staging-networking-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

module "private_hosted_zone" {
  source  = "../../../modules/dns/private-hosted-zone"
  environment = "${var.environment}"
  domain = "${module.aws_dns_mappings.domains_by_environment[var.environment]}"
  region = "${var.region}"
  vpc_id = "${data.terraform_remote_state.staging_networking.staging_vpc_id}"
}

