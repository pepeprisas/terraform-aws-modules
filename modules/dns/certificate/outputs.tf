output "certificate_id" {
  value = "${aws_acm_certificate.cert.*.id}"
}

output "certificate_arn" {
  value = "${aws_acm_certificate.cert.*.arn}"
}

output "certificate_domain_name" {
  value = "${aws_acm_certificate.cert.*.domain_name}"
}
