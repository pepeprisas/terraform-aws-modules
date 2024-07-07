resource "aws_security_group" "es" {
  name        = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-elasticsearch-sg"
  vpc_id      = var.vpc_id
  description = "Allow access to ElasticSearch"

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"

    cidr_blocks = var.cidr_blocks
  }

  tags = {
    Name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-esSg"
    Country = var.country
    Resource = var.resource
    Team = var.team
    Environment = terraform.workspace
    Service = var.service
  }
}

data "aws_caller_identity" "current" {}

resource "aws_cloudwatch_log_group" "es_cloudwatch_group" {
  name              = "/aws/es/${var.country}-${var.team}-${terraform.workspace}-${var.service}"
  retention_in_days = 90
  kms_key_id        = "arn:aws:kms:eu-west-1:12345789012:key/${var.kms_id}"

  tags = {
    Name           = "${var.country}-${var.team}-${terraform.workspace}-${var.service}"
    Country        = var.country
    Resource       = var.resource
    Team           = var.team
    Environment    = terraform.workspace
    Service        = var.service
  }
}

resource "aws_cloudwatch_log_resource_policy" "es_cloudwatch_policy" {
  policy_name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-cloudwatch-policy"
  policy_document = <<CONFIG
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "es.amazonaws.com"
      },
      "Action": [
        "logs:PutLogEvents",
        "logs:PutLogEventsBatch",
        "logs:CreateLogStream"
      ],
      "Resource": "arn:aws:logs:*"
    }
  ]
}
CONFIG
}

resource "aws_elasticsearch_domain" "es_vpc" {
  domain_name           = var.domain_name
  elasticsearch_version = var.es_version

  tags = {
    Name           = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-es"
    Country        = var.country
    Resource       = var.resource
    Team           = var.team
    Environment    = terraform.workspace
    Service        = var.service
  }

  cluster_config {
    instance_type = var.instance_class
  }

  vpc_options {
    subnet_ids = [var.subnet_ids[0]]

    security_group_ids = [aws_security_group.es.id]
  }

  advanced_options = {
    "rest.action.multi.allow_explicit_index" = "true"
  }

  access_policies = <<CONFIG
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "es:*",
            "Principal": "*",
            "Effect": "Allow",
            "Resource": "arn:aws:es:${var.region}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"
        }
    ]
}
CONFIG

  ebs_options {
    ebs_enabled = var.ebs_volume_size > 0 ? true : false
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  encrypt_at_rest {
    enabled     = true
    kms_key_id  = var.kms_id
  }

  snapshot_options {
    automated_snapshot_start_hour = var.snapshot_start_hour
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.es_cloudwatch_group.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

}

resource "aws_route53_record" "es_route53" {
  zone_id = var.route53_zone_id
  name = var.service
  type = "CNAME"
  ttl = 180
  records = [aws_elasticsearch_domain.es_vpc.endpoint]
}
