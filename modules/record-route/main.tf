resource "aws_route53_record" "cname_route53_record" {
  zone_id = var.zoneid
  name    = var.name
  type    = var.type
  ttl     = var.ttl
  records = [var.dnsname]
}