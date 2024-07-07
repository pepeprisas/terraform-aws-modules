resource "aws_acm_certificate" "certificate" {
  domain_name       = var.domain_name
  validation_method = "DNS"
  tags = {
    Name = "${var.country}-${var.team}-${terraform.workspace}-acm-${var.freetext}"
    Country = var.country
    Resource = "acm"
    Environment = terraform.workspace
    Team = var.team
    Service = "certificate"
  }
}

data "aws_route53_zone" "external" {
  name         = var.zone_name
  private_zone = var.private_zone
}

resource "aws_route53_record" "validation" {
  allow_overwrite = true
  name            = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  records         = [ tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value ]
  type            = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_type
  zone_id         = data.aws_route53_zone.external.id
  ttl             = 60
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [
    aws_route53_record.validation.fqdn,
  ]
}
