provider "aws" { region = "${var.region}" }

terraform {
  backend "s3" {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/staging-networking-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    acl     = "bucket-owner-full-control"
  }
}

data "terraform_remote_state" "main_networking" {
  backend = "s3"
  config = {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/main-networking-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
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

module "transit_gateway" {
  source  = "../../../modules/networks/transit-gateway"
  environment = "${var.environment}"
  region = "${var.region}"
}

module "transit_gateway_attachment" {
  source  = "../../../modules/networks/transit-gateway-attachment"
  main_vpc_id = "${data.terraform_remote_state.main_networking.main_vpc_id}"
  vpc_id = "${module.vpc.vpc_id}"
  transit_gw_id = "${module.transit_gateway.transit_gw_id}"
  subnet_ids = "${module.subnets.private_subnets}"
  main_subnet_ids = "${data.terraform_remote_state.main_networking.main_private_subnet_ids}"
  environment = "${var.environment}"
  region = "${var.region}"
  main_cidr = "${lookup(module.aws_networking_mappings.cidrs, var.main)}"
  cidr = "${lookup(module.aws_networking_mappings.cidrs, var.environment)}"
}

module "transit_gateway_routing" {
  source  = "../../../modules/networks/transit-gateway-routing"
  main_private_route_tables = "${data.terraform_remote_state.main_networking.main_private_route_table_ids}"
  main_public_route_table = "${data.terraform_remote_state.main_networking.main_public_route_table_id}"
  private_route_tables = "${module.routing.private_route_table_ids}"
  route_tables_count = "${length(data.terraform_remote_state.main_networking.main_private_route_table_ids)}"
  public_route_table = "${module.routing.public_route_table_id}"
  tgw_id = "${module.transit_gateway.transit_gw_id}"
  main_cidr = "${lookup(module.aws_networking_mappings.cidrs, var.main)}"
  environment_cidr = "${lookup(module.aws_networking_mappings.cidrs, var.environment)}"
}
