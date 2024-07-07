output "private_hosted_zone_id" {
  value = "${aws_route53_zone.private_hosted_zone.id}"
}

output "private_hosted_zone_name" {
  value = "${aws_route53_zone.private_hosted_zone.name}"
}

output "private_hosted_zone_zone_id" {
  value = "${aws_route53_zone.private_hosted_zone.zone_id}"
}
