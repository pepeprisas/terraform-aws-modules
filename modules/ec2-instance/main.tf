data "aws_subnet" "selected" {
  id = var.subnet_id
}

data "aws_caller_identity" "current" {}

data "aws_ami" "devops" {
  most_recent = true

  filter {
    name   = "name"
    values = ["devops/${var.ami_name}"]
  }

  owners = [data.aws_caller_identity.current.account_id]
}


resource "aws_security_group" "ec2-sg" {
  count = var.create_sg
  name = "${var.account}-${terraform.workspace}-${var.service}-sg"
  description = "EC2 security group."


  vpc_id = data.aws_subnet.selected.vpc_id

  //  Use external SG to attach ingress rules using sg-attachement module

  ingress {
    protocol = "tcp"
    from_port = var.from_port
    to_port = var.to_port
    cidr_blocks = var.ipblocks
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.account}-${terraform.workspace}-${var.service}-sg"
    Account = var.account
    Resource = "sg"
    Service = var.service
  }
}


resource "aws_instance" "instance" {
  ami = data.aws_ami.devops.id
  instance_type = var.instance_type
  security_groups = "${var.create_sg}" == 0 ? "${var.sg_ids}" : [aws_security_group.ec2-sg[0].id]
  subnet_id = data.aws_subnet.selected.id
  user_data = var.userdata
  iam_instance_profile = var.instance_profile_role
  root_block_device  {
      volume_type = var.volume_type
      volume_size = var.volume_size
      iops = var.volume_type == "io2"||var.volume_type == "io1" ? var.volume_iops : 0
    }
  tags = {
    Name = "${var.account}-${terraform.workspace}-${var.service}-ec2"
    Account = var.account
    Resource = "ec2"
    Service = var.service
    "Patch Group" = "${lookup(data.aws_ami.devops.tags, "OS_Version")}" == "Ubuntu" ? "ubuntu_instances_${terraform.workspace}" : ("${lookup(data.aws_ami.devops.tags, "OS_Version")}" == "Amazon Linux 2" ? "amazon_linux_2_instances_${terraform.workspace}": "no_group")
  }
  volume_tags = {
    Name = "${var.account}-${terraform.workspace}-${var.service}-volume"
    Account = var.account
    Resource = "volume"
    Service = var.service
  }
}
