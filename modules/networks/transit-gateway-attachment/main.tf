resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_transit_gw_attachment_main" {
  subnet_ids         = ["${var.main_subnet_ids}"]
  transit_gateway_id = "${var.transit_gw_id}"
  vpc_id             = "${var.main_vpc_id}"
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc_transit_gw_attachment_environment" {
  subnet_ids         = ["${var.subnet_ids}"]
  transit_gateway_id = "${var.transit_gw_id}"
  vpc_id             = "${var.vpc_id}"
}


resource "aws_ec2_transit_gateway_route_table" "tgw_route_table_main" {
  transit_gateway_id = "${var.transit_gw_id}"

  tags = {
    Name = "${var.service}-${var.role}-route-table-main-${var.environment}"
    Service = "${var.service}"
    Role = "${var.role}-route-table"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }
}

resource "aws_ec2_transit_gateway_route_table" "tgw_route_table_environment" {
  transit_gateway_id = "${var.transit_gw_id}"

  tags = {
    Name = "${var.service}-${var.role}-route-table-${var.environment}"
    Service = "${var.service}"
    Role = "${var.role}-route-table"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }
}

resource "aws_ec2_transit_gateway_route" "tgw_route_main" {
  destination_cidr_block         = "${var.cidr}"
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.vpc_transit_gw_attachment_main.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw_route_table_main.id}"

  depends_on                = ["aws_ec2_transit_gateway_route_table.tgw_route_table_main"]
}

resource "aws_ec2_transit_gateway_route" "tgw_route_environment" {
  destination_cidr_block         = "${var.main_cidr}"
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.vpc_transit_gw_attachment_environment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw_route_table_environment.id}"

  depends_on                = ["aws_ec2_transit_gateway_route_table.tgw_route_table_environment"]
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_propagation_environment" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.vpc_transit_gw_attachment_environment.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw_route_table_environment.id}"
}

resource "aws_ec2_transit_gateway_route_table_propagation" "tgw_propagation_main" {
  transit_gateway_attachment_id  = "${aws_ec2_transit_gateway_vpc_attachment.vpc_transit_gw_attachment_main.id}"
  transit_gateway_route_table_id = "${aws_ec2_transit_gateway_route_table.tgw_route_table_environment.id}"
}