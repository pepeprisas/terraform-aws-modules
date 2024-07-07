provider "aws" { region = "${var.region}" }

terraform {
  backend "s3" {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/main-vpnc-eu-west-1.tfstate"
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
  config = {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/main-networking-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
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

data "terraform_remote_state" "production_networking" {
  backend = "s3"
  config = {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/production-networking-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}




resource "aws_iam_role" "vpn_role" {
  name = "${var.service}-${var.role}-iam-role-${var.environment}-${var.region}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "vpn_policy" {
  name = "${var.service}-${var.role}-iam-policy-${var.environment}-${var.region}"
  role = "${aws_iam_role.vpn_role.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ssm:DescribeAssociation",
                "ssm:GetDeployablePatchSnapshotForInstance",
                "ssm:GetDocument",
                "ssm:GetManifest",
                "ssm:GetParameters",
                "ssm:ListAssociations",
                "ssm:ListInstanceAssociations",
                "ssm:PutInventory",
                "ssm:PutComplianceItems",
                "ssm:PutConfigurePackageResult",
                "ssm:UpdateAssociationStatus",
                "ssm:UpdateInstanceAssociationStatus",
                "ssm:UpdateInstanceInformation"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ssmmessages:CreateControlChannel",
                "ssmmessages:CreateDataChannel",
                "ssmmessages:OpenControlChannel",
                "ssmmessages:OpenDataChannel"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2messages:AcknowledgeMessage",
                "ec2messages:DeleteMessage",
                "ec2messages:FailMessage",
                "ec2messages:GetEndpoint",
                "ec2messages:GetMessages",
                "ec2messages:SendReply"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeInstances",
                "ec2:DescribeTags",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:ModifyInstanceAttribute",
                "ec2:ReplaceRoute"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ds:CreateComputer",
                "ds:DescribeDirectories"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "vpn_profile" {
  name = "${var.service}-${var.role}-instance-profile-${var.environment}-${var.region}"
  role = "${aws_iam_role.vpn_role.name}"
}

resource "aws_security_group" "vpn_ec2_sg" {
  name = "${var.service}-${var.role}-secg-${var.environment}-${var.region}"
  description = "${var.role} vpn"
  vpc_id = "${data.terraform_remote_state.main_networking.main_vpc_id}"

  ingress {
    from_port = "443"
    to_port = "443"
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "tcp"
  }

  ingress {
    from_port = "1194"
    to_port = "1194"
    cidr_blocks = ["0.0.0.0/0"]
    protocol = "udp"
  }

  ingress {
    from_port = 0
    to_port = 0
    cidr_blocks = ["172.16.0.0/16","172.17.0.0/16","172.18.0.0/16"]
    protocol = "tcp"
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "vpn_ec2" {
  ami = "${module.aws_ami_mappings.amis["vpnc"]}"
  instance_type = "${var.instance_type}"
  subnet_id= "${data.terraform_remote_state.main_networking.main_public_subnet_ids[0]}"
  vpc_security_group_ids = [ "${aws_security_group.vpn_ec2_sg.id}" ]
  iam_instance_profile = "${aws_iam_instance_profile.vpn_profile.name}"
  source_dest_check = false
  key_name = "keyname"

  root_block_device {
    volume_size = "${var.storage_size}"
    volume_type = "gp2"
  }
}

resource "aws_eip" "vpn_eip" {
  instance = "${aws_instance.vpn_ec2.id}"
  vpc      = true
}

resource "aws_route53_record" "vpn_route53" {
  zone_id = "${module.aws_dns_mappings.main_public_hosted_zone_id}"
  name = "${var.hostname}"
  type = "A"
  ttl = 300
  records = ["${aws_eip.vpn_eip.public_ip}"]
}


resource "aws_route" "vpn_route_public_main" {
  route_table_id = "${data.terraform_remote_state.main_networking.main_public_route_table_id}"
  destination_cidr_block = "${var.vpn_cidr}"
  instance_id = "${aws_instance.vpn_ec2.id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "vpn_route_private_main" {
  count = "${length(data.terraform_remote_state.main_networking.main_private_route_table_ids)}"
  route_table_id         = "${data.terraform_remote_state.main_networking.main_private_route_table_ids[count.index]}"
  destination_cidr_block = "${var.vpn_cidr}"
  instance_id = "${aws_instance.vpn_ec2.id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "vpn_route_public_staging" {
  route_table_id = "${data.terraform_remote_state.staging_networking.staging_public_route_table_id}"
  destination_cidr_block = "${var.vpn_cidr}"
  transit_gateway_id = "${data.terraform_remote_state.staging_networking.staging_tgw_id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "vpn_route_private_staging" {
  count = "${length(data.terraform_remote_state.staging_networking.staging_private_route_table_ids)}"
  route_table_id         = "${data.terraform_remote_state.staging_networking.staging_private_route_table_ids[count.index]}"
  destination_cidr_block = "${var.vpn_cidr}"
  transit_gateway_id     = "${data.terraform_remote_state.staging_networking.staging_tgw_id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "vpn_route_public_production" {
  route_table_id = "${data.terraform_remote_state.production_networking.production_public_route_table_id}"
  destination_cidr_block = "${var.vpn_cidr}"
  transit_gateway_id = "${data.terraform_remote_state.production_networking.production_tgw_id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "vpn_route_private_production" {
  count = "${length(data.terraform_remote_state.production_networking.production_private_route_table_ids)}"
  route_table_id         = "${data.terraform_remote_state.production_networking.production_private_route_table_ids[count.index]}"
  destination_cidr_block = "${var.vpn_cidr}"
  transit_gateway_id     = "${data.terraform_remote_state.production_networking.production_tgw_id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_ec2_transit_gateway_route" "tgw_route_vpn_staging_to_main" {
  destination_cidr_block         = "${var.vpn_cidr}"
  transit_gateway_attachment_id  = "${data.terraform_remote_state.staging_networking.staging_tgw_attachment_main_id}"
  transit_gateway_route_table_id = "${data.terraform_remote_state.staging_networking.staging_tgw_route_table_environment_id}"
}

resource "aws_ec2_transit_gateway_route" "tgw_route_vpn_production_to_main" {
  destination_cidr_block         = "${var.vpn_cidr}"
  transit_gateway_attachment_id  = "${data.terraform_remote_state.production_networking.production_tgw_attachment_main_id}"
  transit_gateway_route_table_id = "${data.terraform_remote_state.production_networking.production_tgw_route_table_environment_id}"
}

resource "aws_ec2_transit_gateway_route" "tgw_route_vpn_staging_to_main_default" {
  destination_cidr_block         = "${var.vpn_cidr}"
  transit_gateway_attachment_id  = "${data.terraform_remote_state.staging_networking.staging_tgw_attachment_main_id}"
  transit_gateway_route_table_id = "${data.terraform_remote_state.staging_networking.staging_tgw_default_route_table_id}"
}

resource "aws_ec2_transit_gateway_route" "tgw_route_vpn_production_to_main_default" {
  destination_cidr_block         = "${var.vpn_cidr}"
  transit_gateway_attachment_id  = "${data.terraform_remote_state.production_networking.production_tgw_attachment_main_id}"
  transit_gateway_route_table_id = "${data.terraform_remote_state.production_networking.production_tgw_default_route_table_id}"
}
