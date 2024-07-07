provider "aws" {
  region = "eu-west-1"
}
data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret_version" "user" {
  secret_id = var.secretid
}
data "aws_secretsmanager_secret_version" "password" {
  secret_id = var.secretid
}
resource "aws_security_group" "codebuildsg" {
  name        = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-sg-${var.name}"
  description = "codebuild SG"

  vpc_id = var.vpc_id


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-sg-${var.name}"
    Country     = var.country
    Team        = var.team
    Environment = terraform.workspace
    Service     = var.service
    Autoremove  = "False"

  }
}

resource "aws_codebuild_webhook" "webhook" {
  project_name = aws_codebuild_project.codebuildproject.name

  filter_group {
    filter {
      type    = "EVENT"
      pattern = "PULL_REQUEST_CREATED, PULL_REQUEST_UPDATED"
    }

  }
}
resource "aws_iam_role" "codebuildrole" {
  name = "es-data-codebuildrole-${var.name}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

  tags = {
    Name        = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-role-${var.name}"
    Country     = var.country
    Team        = var.team
    Environment = terraform.workspace
    Service     = var.service

  }
}
resource "aws_iam_role_policy" "codebuildpolicy" {

  name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-policy-${var.name}"

  role = aws_iam_role.codebuildrole.name

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ecr:CompleteLayerUpload",
                "ecr:GetAuthorizationToken",
                "ecr:UploadLayerPart",
                "ecr:InitiateLayerUpload",
                "ecr:BatchCheckLayerAvailability",
                "ecr:PutImage"
            ],
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "ecr:ResourceTag/Team": "${var.team}"
                }
            }
        },
        {
           "Effect": "Allow",
            "Action": [
                "secretsmanager:GetResourcePolicy",
                "secretsmanager:GetSecretValue",
                "secretsmanager:DescribeSecret",
                "secretsmanager:ListSecretVersionIds"
            ],
            "Resource": "arn:aws:secretsmanager:*:${data.aws_caller_identity.current.account_id}:secret:*"
        },
        {
            "Effect": "Allow",
            "Action": "ecs:RunTask",
            "Resource": "*",
            "Condition": {
                "StringLike": {
                    "ecs:ResourceTag/Team": "${var.team}"
                }
            }
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DeleteNetworkInterface",
                "ec2:DescribeDhcpOptions",
                "ssm:GetParameters",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "ec2:DescribeSecurityGroups",
                "ec2:CreateNetworkInterface",
                "logs:CreateLogStream",
                "iam:PassRole",
                "ec2:DescribeNetworkInterfaces",
                "ec2:CreateNetworkInterfacePermission",
                "ec2:DescribeVpcs",
                "ec2:DescribeSubnets"
            ],
            "Resource": "*"
        },
            {
      "Effect": "Allow",
      "Action": [
        "ec2:CreateNetworkInterfacePermission"
      ],
      "Resource": [
        "arn:aws:ec2:eu-west-1:arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:network-interface/*"
      ],
      "Condition": {
        "StringEquals": {
          "ec2:Subnet": [
            "arn:aws:ec2:eu-west-1:arn:aws:kms:${var.region}:${data.aws_caller_identity.current.account_id}:subnet/${var.subnet_id}"
          ],
          "ec2:AuthorizedService": "codebuild.amazonaws.com"
        }
      }
    }
    ]
}
POLICY

}


resource "aws_codebuild_source_credential" "credentials" {
  auth_type   = "BASIC_AUTH"
  server_type = "GITHUB"
  token       = jsondecode(data.aws_secretsmanager_secret_version.user.secret_string)["password"]
  user_name   = jsondecode(data.aws_secretsmanager_secret_version.user.secret_string)["user"]
}

resource "aws_codebuild_project" "codebuildproject" {
  name          = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-codebuild-${var.name}"
  description   = "${var.name}_codebuild_project"
  build_timeout = "5"
  service_role  = aws_iam_role.codebuildrole.arn

  artifacts {
    type = "NO_ARTIFACTS"
  }


  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = var.image
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    environment_variable {
      name  = "sonardns"
      value = var.sonardns
    }

    environment_variable {
      name  = "sonarproject"
      value = var.sonarproject
    }
    environment_variable {
      name  = "githubproject"
      value = var.githubproject
    }
  }

  logs_config {
    cloudwatch_logs {
      group_name  = "log-group"
      stream_name = "log-stream"
    }
  }

  source {
    buildspec       = var.buildspec
    type            = "GITHUB"
    location        = "https://${jsondecode(data.aws_secretsmanager_secret_version.user.secret_string)["user"]}@github.com/${var.githubproject}.git"
    git_clone_depth = 1
    auth {
      type     = "OAUTH"
      resource = aws_codebuild_source_credential.credentials.arn
    }
    git_submodules_config {
      fetch_submodules = false
    }
  }

  /* source_version = "master" */

  vpc_config {
    vpc_id = var.vpc_id

    subnets = [
      var.subnet_id
    ]

    security_group_ids = [
      aws_security_group.codebuildsg.id
    ]
  }

  tags = {
    Name        = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-codebuild-${var.name}"
    Country     = var.country
    Team        = var.team
    Environment = terraform.workspace
    Service     = var.service

  }
}
