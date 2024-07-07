output "gw_id" {
  value = "${aws_internet_gateway.igw.id}"
}

output "ngw_id" {
  value = "${aws_nat_gateway.nat_gw.id}"
}

output "public_route_table_id" {
  value = "${aws_route_table.public_route_table.id}"
}

output "private_route_table_ids" {
  value = ["${aws_route_table.private_route_table.*.id}"]
}
