data "aws_subnet" "selected" {
  id = var.subnet_id
}

resource "aws_security_group" "connect-sg" {
  name = "${var.service}-${var.environment}-${var.engine}-ec-connect-sg"
  description = "Allows connections to ${var.service} on ${var.environment}"
  vpc_id = data.aws_subnet.selected.vpc_id


  tags = {
    Name = "${var.service}-${var.environment}-${var.engine}-ec-connect-sg"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}


resource "aws_security_group" "ec-sg" {
  name = "${var.service}-${var.environment}-${var.engine}-ec-sg"
  description = "Elasticache security group."
  vpc_id = data.aws_subnet.selected.vpc_id

  ingress {
    protocol = "tcp"
    from_port = var.port
    to_port = var.port
    cidr_blocks = [
      "0.0.0.0/0"]
    security_groups = [
      aws_security_group.connect-sg.name]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  tags = {
    Name = "${var.service}-${var.environment}--${var.engine}-ec-sg"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}

resource "aws_elasticache_parameter_group" "ec-pg" {
  name   = "${var.service}-${var.environment}--${var.engine}-pg"
  family = var.family
}


resource "aws_elasticache_cluster" "ec" {
  cluster_id           = "${var.service}-${var.environment}-${var.engine}-ec"
  engine               = var.engine
  node_type            = var.node_type
  num_cache_nodes      = var.num_cache_nodes
  parameter_group_name = aws_elasticache_parameter_group.ec-pg.name
  engine_version       = var.engine == "redis" ? var.engine_version : null
  port                 = var.port

  tags = {
    Name = "${var.service}-${var.environment}-${var.engine}-ec"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}


