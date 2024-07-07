//provider "aws" {
//  region          = var.region
//}

data "archive_file" "lambdaZip" {
    type          = "zip"
    source_file   = "./script/${var.function}/index.py"
    output_path   = "./function/${var.function}.zip"
}

locals {
  freetext = var.freetext == null ? "" : "-${var.freetext}"
}

resource "aws_lambda_function" "lambdaFunction" {
  filename         = "./function/${var.function}.zip"
  function_name    = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-lambda${local.freetext}"
  role             = aws_iam_role.lambdaRole.arn
  handler          = "index.handler"
  source_code_hash = data.archive_file.lambdaZip.output_base64sha256
  runtime          = "python3.7"
  timeout = 30
  memory_size = 128

  dynamic "vpc_config" {
    for_each = var.vpcs
    content {
      subnet_ids = vpc_config.value.subnet_ids
      security_group_ids = vpc_config.value.security_group_ids
    }
  }

  tags = {
    Name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-lambda${local.freetext}"
    Country = var.country
    Team = var.team
    Environment = terraform.workspace
    Resource = "lambda"
    Service = var.service
  }
}

// ---------------- IAM Policy definition and role creation ---------------------

resource "aws_iam_policy" "lambdaPolicy" {
  name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-lambdaIamPolicy${local.freetext}"
  policy = data.aws_iam_policy_document.lambdaIam.json
}


data "aws_iam_policy_document" "source" {

  statement {
    sid = "LambdalogginginCloudWatch"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "aws_iam_policy_document" "lambdaIam" {
  source_json = data.aws_iam_policy_document.source.json

  statement {
    sid = "LambdaReadOnlyEC2"
    actions = [
      "ec2:Describe*"
    ]

    resources = ["*"]
  }

  statement {
    sid = "LambdaOperationsS3"
    actions = [
        "s3:GetObject",
        "s3:GetObjectAcl",
        "s3:GetObjectTagging",
        "s3:GetObjectVersion",
        "s3:GetObjectVersionAcl",
        "s3:ListBucket",
        "s3:PutObject",
        "s3:PutObjectAcl",
        "s3:PutObjectTagging",
        "s3:PutObjectVersionAcl",
    ]

    # TODO: fix restrictions
    # resources = ["${var.s3_bucket_arn}", "${var.s3_bucket_arn}${var.s3_bucket_item}*"]
    resources = ["*"]
  }
}


resource "aws_iam_role" "lambdaRole" {
  name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-lambdaIamRole${local.freetext}"
  assume_role_policy = data.aws_iam_policy_document.assumeRoleLambdaIam.json
  tags = {
    Environment = terraform.workspace
    Name  = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-lambdaIamRole${local.freetext}"
    Country = var.country
    Resource = "tg"
    Environment = terraform.workspace
    Team = var.team
    Service = var.service
  }
}

data "aws_iam_policy_document" "assumeRoleLambdaIam" {
  statement {
    sid = "1"

    actions = [
      "sts:AssumeRole"
    ]

    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
  }
}

resource "aws_iam_role_policy_attachment" "attachment" {
  role       = aws_iam_role.lambdaRole.name
  policy_arn = aws_iam_policy.lambdaPolicy.arn
}
