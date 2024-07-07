output "main_vpc_id" {
  value = "${module.vpc.vpc_id}"
}

output "main_public_subnet_ids" {
  value = "${module.subnets.public_subnets}"
}

output "main_private_subnet_ids" {
  value = "${module.subnets.private_subnets}"
}

output "main_public_route_table_id" {
  value = "${module.routing.public_route_table_id}"
}

output "main_private_route_table_ids" {
  value = "${module.routing.private_route_table_ids}"
}