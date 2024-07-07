provider "aws" { region = "${var.region}" }

terraform {
  backend "s3" {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/main-eks-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
    acl     = "bucket-owner-full-control"
  }
}

module "aws_dns_mappings" {
  source  = "../../../mappings/dns"
}

module "aws_ami_mappings" {
  source  = "../../../mappings/amis"
}

data "terraform_remote_state" "main_networking" {
  backend = "s3"
  config {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/main-networking-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

module "eks_cluster" {
  source       = "terraform-aws-modules/eks/aws"

  cluster_name = "${var.service}-${var.role}-${var.environment}-${var.region}"
  subnets      = "${concat(data.terraform_remote_state.main_networking.main_private_subnet_ids,data.terraform_remote_state.main_networking.main_public_subnet_ids)}"
  vpc_id       = "${data.terraform_remote_state.main_networking.main_vpc_id}"

  worker_groups = [
    {
      instance_type = "m4.large"
      asg_max_size  = 6
      asg_min_size = 3
      asg_desired_capacity = 3
    }
  ]

  tags = {
    Name = "${var.service}-${var.role}-${var.environment}-${var.region}"
    Service = "${var.service}"
    Role = "${var.role}"
    Environmnent ="${var.environment}"
    Region ="${var.region}"
  }
}

