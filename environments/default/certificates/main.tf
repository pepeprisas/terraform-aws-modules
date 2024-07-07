variable "region" { default = "eu-west-1" }

provider "aws" { region = "${var.region}" }

terraform {
  backend "s3" {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/default-certificates-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    acl     = "bucket-owner-full-control"
  }
}

module "aws_dns" {
  source  = "../../../mappings/dns"
}

module "certificate" {
  source  = "../../../modules/dns/certificate"
  domains = "${module.aws_dns.domains}"
  environments = "${module.aws_dns.domain_environments}"
  region = "${var.region}"
}
