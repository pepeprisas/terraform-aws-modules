provider "aws" { region = "${var.region}" }

data "archive_file" "lambda_function" {
  type        = "zip"
  source_file = "${path.module}/lambda/handler.py"
  output_path = "/tmp/lambda.zip"
}

resource "aws_iam_role" "sns_proxy_lambda_role" {
  name = "${var.service}-${var.role}-${var.region}-${var.environment}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${var.service}-${var.role}-${var.region}-${var.environment}-lambda-policy"
  path = "/"
  description = "Lambda notification proxy policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:CreateLogGroup"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    },
    {
        "Effect": "Allow",
        "Action": [
            "ec2:CreateNetworkInterface",
            "ec2:DeleteNetworkInterface",
            "ec2:DescribeNetworkInterfaces"
        ],
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role = "${aws_iam_role.sns_proxy_lambda_role.name}"
  policy_arn = "${aws_iam_policy.lambda_policy.arn}"
}

resource "aws_security_group" "lambda_sg" {
  name        = "${var.service}-${var.role}-${var.region}-${var.environment}-lambda-sg"
  description = "allow inbound traffic from VPC"
  vpc_id      = "${var.vpc_id}"

  ingress {
    protocol        = "-1"
    from_port       = 0
    to_port         = 0
    cidr_blocks = ["${var.vpc_cidr}"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.service}-${var.role}-${var.region}-${var.environment}-lambda-sg"
    Service = "${var.service}"
    Role = "${var.role}"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }
}


resource "aws_lambda_function" "sns_proxy_lambda" {
  filename      = "/tmp/lambda.zip"
  function_name = "${var.service}-${var.role}-${var.region}-${var.environment}-lambda"
  role          = "${aws_iam_role.sns_proxy_lambda_role.arn}"
  handler       = "handler.lambda_handler"

  source_code_hash = "${data.archive_file.lambda_function.output_base64sha256}"

  runtime = "python3.6"

  depends_on    = ["aws_iam_role_policy_attachment.lambda_logs", "data.archive_file.lambda_function"]

  vpc_config {
    subnet_ids         = ["${split(", ", var.subnet_ids)}"]
    security_group_ids = ["${aws_security_group.lambda_sg.id}"]
  }

  environment {
    variables = {
      notification_endpoint = "${var.notification_endpoint}"
    }
  }

  tags = {
    Name = "${var.service}-${var.role}-${var.region}-${var.environment}-lambda"
    Service = "${var.service}"
    Role = "${var.role}"
    Environment ="${var.environment}"
    Region ="${var.region}"
  }
}

resource "aws_lambda_permission" "with_sns" {
  statement_id = "AllowExecutionFromSNS"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.sns_proxy_lambda.arn}"
  principal = "sns.amazonaws.com"
}

