# Create a VPC to launch build instances into
resource "aws_vpc" "vpc_id" {
  cidr_block           = "${var.cidr_block}"
  enable_dns_hostnames = true
  enable_dns_support   = true
  instance_tenancy     = "default"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.service}-${var.environment}-${var.region}"
    Service = "${var.service}"
    Role = "${var.role}"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }
}

# Create dhcp option setup
resource "aws_vpc_dhcp_options" "vpc_dhcp_id" {
  domain_name         = "${var.region}.compute.internal"
  domain_name_servers = ["AmazonProvidedDNS"]

  tags = {
    Name = "${var.service}-dchp-${var.environment}-${var.region}"
    Service = "${var.service}"
    Role = "DHCP"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }
}

resource "aws_vpc_dhcp_options_association" "dns_resolver" {
  vpc_id          = "${aws_vpc.vpc_id.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.vpc_dhcp_id.id}"
}
