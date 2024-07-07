output "vpc_id" {
  value = "${aws_vpc.vpc_id.id}"
}

output "vpc_cidr_block" {
  value = "${aws_vpc.vpc_id.cidr_block}"
}

output "main_route_table_id" {
  value = "${aws_vpc.vpc_id.main_route_table_id}"
}

output "vpc_dhcp_id" {
  value = "${aws_vpc_dhcp_options.vpc_dhcp_id.id}"
}
