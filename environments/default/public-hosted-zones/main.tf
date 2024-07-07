provider "aws" { region = "${var.region}" }

terraform {
  backend "s3" {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/default-public-hosted-zones-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    acl     = "bucket-owner-full-control"
  }
}

module "aws_dns_mappings" {
  source  = "../../../mappings/dns"
}

module "public_hosted_zone" {
  source  = "../../../modules/dns/public-hosted-zone"
  environments = "${module.aws_dns_mappings.domain_environments}"
  domains = "${module.aws_dns_mappings.domains}"
  region = "${var.region}"
}
