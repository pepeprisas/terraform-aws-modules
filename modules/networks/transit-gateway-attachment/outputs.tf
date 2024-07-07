output "transit_gw_attachment_main_id" {
  value = "${aws_ec2_transit_gateway_vpc_attachment.vpc_transit_gw_attachment_main.id}"
}

output "transit_gw_attachment_environment_id" {
  value = "${aws_ec2_transit_gateway_vpc_attachment.vpc_transit_gw_attachment_environment.id}"
}

output "transit_gw_route_table_main_id" {
  value = "${aws_ec2_transit_gateway_route_table.tgw_route_table_main.id}"
}

output "transit_gw_route_table_environment_id" {
  value = "${aws_ec2_transit_gateway_route_table.tgw_route_table_environment.id}"
}