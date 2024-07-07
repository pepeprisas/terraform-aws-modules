
resource "aws_ecr_repository" "default" {
  name   = "${var.account}-${terraform.workspace}-${var.service}-ecr"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
    kms_key = var.kms_key
  }
  tags = {
    Environment = terraform.workspace
    Name  = "${var.account}-${terraform.workspace}-${var.service}-ecr"
    Account = var.account
    Resource = "ecr"
    Service = var.service
  }
}

resource "aws_ecr_lifecycle_policy" "default" {
  repository = aws_ecr_repository.default.name

  policy = <<EOF
{
  "rules": [{
    "rulePriority": 1,
    "description": "Rotate images when reach ${var.max_image_count} images stored",
    "selection": {
      "tagStatus": "tagged",
      "tagPrefixList": ["${terraform.workspace}"],
      "countType": "imageCountMoreThan",
      "countNumber": ${var.max_image_count}
    },
    "action": {
      "type": "expire"
    }
  }]
}
EOF
}