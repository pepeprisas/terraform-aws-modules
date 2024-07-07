resource "aws_route" "main_public_tgw_routes" {
  route_table_id         = "${var.main_public_route_table}"
  destination_cidr_block = "${var.environment_cidr}"
  transit_gateway_id     = "${var.tgw_id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "main_private_tgw_routes" {
  count                  = "${var.route_tables_count}"
  route_table_id         = "${var.main_private_route_tables[count.index]}"
  destination_cidr_block = "${var.environment_cidr}"
  transit_gateway_id     = "${var.tgw_id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "environment_private_tgw_routes" {
  count                  = "${var.route_tables_count}"
  route_table_id         = "${var.private_route_tables[count.index]}"
  destination_cidr_block = "${var.main_cidr}"
  transit_gateway_id     = "${var.tgw_id}"

  timeouts {
    create = "5m"
  }
}

resource "aws_route" "environmente_public_tgw_routes" {
  route_table_id         = "${var.public_route_table}"
  destination_cidr_block = "${var.main_cidr}"
  transit_gateway_id     = "${var.tgw_id}"

  timeouts {
    create = "5m"
  }
}