resource "aws_ec2_transit_gateway" "default_transit_gw" {
  auto_accept_shared_attachments = "enable"

  tags = {
    Name = "${var.service}-${var.role}-${var.environment}"
    Service = "${var.service}"
    Role = "${var.role}"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }
}

