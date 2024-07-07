provider "aws" { region = "${var.region}" }

terraform {
  backend "s3" {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/main-networking-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    acl     = "bucket-owner-full-control"
  }
}


module "aws_networking_mappings" {
  source  = "../../../mappings/networks"
}

module "vpc" {
  source  = "../../../modules/networks/vpc"
  cidr_block = "${lookup(module.aws_networking_mappings.cidrs, var.environment)}"
  environment = "${var.environment}"
  region = "${var.region}"
  role = "${var.environment}"
}

module "subnets" {
  source  = "../../../modules/networks/subnet"
  vpc_id = "${module.vpc.vpc_id}"
  vpc_cidr_prefix = "${lookup(module.aws_networking_mappings.cidrs_prefixes, var.environment)}"
  vpc_cidr_block = "${lookup(module.aws_networking_mappings.cidrs_blocks, var.environment)}"
  availability_zones = "${module.aws_networking_mappings.availability_zones}"
  environment = "${var.environment}"
  region = "${var.region}"
}

module "routing" {
  source  = "../../../modules/networks/routing"
  vpc_id = "${module.vpc.vpc_id}"
  private_subnet_ids = "${module.subnets.private_subnets}"
  public_subnet_ids = "${module.subnets.public_subnets}"
  items = "${length(keys(module.aws_networking_mappings.availability_zones))}"
  environment = "${var.environment}"
  region = "${var.region}"
}