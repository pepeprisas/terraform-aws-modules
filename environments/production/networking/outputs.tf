output "production_vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "production_public_subnet_ids" {
  value = "${module.subnets.public_subnets}"
}

output "production_private_subnet_ids" {
  value = "${module.subnets.private_subnets}"
}

output "production_public_route_table_id" {
  value = "${module.routing.public_route_table_id}"
}

output "production_private_route_table_ids" {
  value = "${module.routing.private_route_table_ids}"
}

output "production_tgw_id" {
  value = "${module.transit_gateway.transit_gw_id}"
}

output "production_tgw_route_table_main_id" {
  value = "${module.transit_gateway_attachment.transit_gw_route_table_main_id}"
}

output "production_tgw_route_table_environment_id" {
  value = "${module.transit_gateway_attachment.transit_gw_route_table_environment_id}"
}

output "production_tgw_attachment_main_id" {
  value = "${module.transit_gateway_attachment.transit_gw_attachment_main_id}"
}

output "production_tgw_attachment_environment_id" {
  value = "${module.transit_gateway_attachment.transit_gw_attachment_environment_id}"
}

output "production_tgw_default_route_table_id" {
  value = "${module.transit_gateway.transit_gw_default_route_table}"
}

output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "public_subnet_ids" {
  value = "${module.subnets.public_subnets}"
}

output "private_subnet_ids" {
  value = "${module.subnets.private_subnets}"
}

output "public_route_table_id" {
  value = "${module.routing.public_route_table_id}"
}

output "private_route_table_ids" {
  value = "${module.routing.private_route_table_ids}"
}

output "tgw_id" {
  value = "${module.transit_gateway.transit_gw_id}"
}

output "tgw_route_table_main_id" {
  value = "${module.transit_gateway_attachment.transit_gw_route_table_main_id}"
}

output "tgw_route_table_environment_id" {
  value = "${module.transit_gateway_attachment.transit_gw_route_table_environment_id}"
}

output "tgw_attachment_environment_id" {
  value = "${module.transit_gateway_attachment.transit_gw_attachment_environment_id}"
}

output "tgw_attachment_main_id" {
  value = "${module.transit_gateway_attachment.transit_gw_attachment_main_id}"
}

output "tgw_default_route_table_id" {
  value = "${module.transit_gateway.transit_gw_default_route_table}"
}