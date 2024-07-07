provider "aws" {
  region  = var.region
}

resource "null_resource" "dockerBuild" {
    provisioner "local-exec" {
        command = "docker build -t lambda/${var.image} ."
    }
}

resource "aws_ecr_repository" "ecrRepository" {
  depends_on 		= [null_resource.dockerBuild]
  name			= "lambda/${var.image}"
  image_tag_mutability	= "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "repoPolicy" {
  repository = aws_ecr_repository.ecrRepository.name
  policy     = <<EOF
  {
    "Version": "2008-10-17",
    "Statement": [
      {
        "Sid": "adds full ecr access to the repository",
        "Effect": "Allow",
        "Principal": "*",
        "Action": [
          "ecr:BatchCheckLayerAvailability",
          "ecr:BatchGetImage",
          "ecr:CompleteLayerUpload",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetLifecyclePolicy",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
      }
    ]
  }
  EOF
}



locals {
  freetext = var.freetext == null ? "" : "-${var.freetext}"
}

resource "null_resource" "dockerTag" {
  depends_on  = [aws_ecr_repository_policy.repoPolicy]
  provisioner "local-exec" {
    command   = "docker tag lambda/${var.image}:latest ${aws_ecr_repository.ecrRepository.repository_url}:latest"
  }
}

resource "null_resource" "dockerPush" {
  depends_on  = [null_resource.dockerTag]
  provisioner "local-exec" {
    command = "docker push ${aws_ecr_repository.ecrRepository.repository_url}:latest"
  }
}

resource "aws_lambda_function" "lambdaFunction" {
  depends_on       = [null_resource.dockerPush]
  image_uri	   = "${aws_ecr_repository.ecrRepository.repository_url}:latest"
  package_type	   = "Image"
  function_name    = "${var.country}-${var.team}-${var.environment}-${var.service}-lambda-${local.freetext}"
  role             = aws_iam_role.lambdaRole.arn
  handler          = "index.handler"
  timeout = 30
  memory_size = 128

  tags = {
    Name = "${var.country}-${var.team}-${var.environment}-${var.service}-lambda-${local.freetext}"
    Country = var.country
    Team = var.team
    Environment = var.environment
    Resource = "lambda"
    Service = var.service
  }
}

// ---------------- IAM Policy definition and role creation ---------------------

resource "aws_iam_policy" "lambdaPolicy" {
  name = "${var.country}-${var.team}-${var.environment}-${service}-lambdaIamPolicy-${local.freetext}"
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
    sid = "LambdaIAM"
    actions = [
      "iam:ListUsers"
    ]

    resources = ["*"]
  }

}


resource "aws_iam_role" "lambdaRole" {
  name = "${var.country}-${var.team}-${var.environment}-${var.service}-lambdaIamRole-${local.freetext}"
  assume_role_policy = data.aws_iam_policy_document.assumeRoleLambdaIam.json
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
