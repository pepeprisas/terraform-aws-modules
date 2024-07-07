output "transit_gw_id" {
  value = "${aws_ec2_transit_gateway.default_transit_gw.id}"
}

output "transit_gw_default_route_table" {
  value = "${aws_ec2_transit_gateway.default_transit_gw.association_default_route_table_id}"
}
