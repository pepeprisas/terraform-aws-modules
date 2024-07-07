data "aws_subnet" "selected" {
  id = var.subnet_id
}

data "terraform_remote_state" "environment_networking" {
  backend = "s3"
  config = {
    bucket  = "main-eu-west-1-terraform-state-bucket"
    key     = "terraform-state/${terraform.workspace}-networking-eu-west-1.tfstate"
    region  = "eu-west-1"
    encrypt = "true"
  }
}

resource "aws_security_group" "connect-sg" {
  name = "${var.service}-${var.environment}-${var.engine}-conn-sg"
  description = "Allows connections to ${var.service} on ${var.environment}"
  #vpc_id = data.terraform_remote_state.environment_networking.outputs.vpc_id      ##data.aws_subnet.selected.vpc_id 
  vpc_id = data.aws_subnet.selected.vpc_id
  tags = {
    Name = "${var.service}-${var.environment}-${var.engine}-ec-sg"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}


resource "aws_security_group" "ec-sg" {
  name = "${var.service}-${var.environment}-${var.engine}-ec-sg"
  description = "Elasticache security group."
  vpc_id = data.aws_subnet.selected.vpc_id  #  "vpc-097e2a6f"
  tags = {
    Name = "${var.service}-${var.environment}-${var.engine}-ec-sg"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}

resource "aws_elasticache_parameter_group" "ec-pg" {
  name   = "${var.service}-${var.environment}-${var.engine}-pg"
  family = var.family
}

resource "aws_elasticache_subnet_group" "redis" {
  name        = "${var.service}-${var.environment}-subnet"
  subnet_ids  = [var.subnet_id]
  description = "${var.service}-${var.environment}-subnet"
}

resource "aws_elasticache_replication_group" "cluster_redis" {
  replication_group_id = "${var.service}-${var.environment}-${var.engine}-ec"
  automatic_failover_enabled    = false
  security_group_ids            = concat(var.security_group_ids, [aws_security_group.redis.id])
  availability_zones            = ["eu-west-1a"]
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  replication_group_description = "${var.service}-${var.environment}-${var.engine}-ec"
  node_type                     = "cache.t3.micro" # "cache.t3.small"
  number_cache_clusters         = 1
  parameter_group_name          = aws_elasticache_parameter_group.ec-pg.name
  port                          = 6379
  tags = {
    Name = "${var.service}-${var.environment}-${var.engine}-ec"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}


resource "aws_security_group" "redis" {
  name_prefix = "${var.service}-${var.environment}-redis-sg"
  vpc_id      = var.vpc_id
  tags = {
    Name = "${var.service}-${var.environment}-${var.engine}-ec-sg"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}

resource "aws_security_group_rule" "redis_ingress_cidr_blocks" {
  count = length(var.ingress_cidr_blocks) != 0 ? 1 : 0

  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.ingress_cidr_blocks
  security_group_id = aws_security_group.redis.id
}

resource "aws_security_group_rule" "redis_egress" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.redis.id
}

