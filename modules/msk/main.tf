data "aws_subnet" "selected" {
  id = var.subnets[0]
}


resource "aws_security_group" "connect-sg" {
  name = "${var.service}-${var.environment}-msk-connect-sg"
  description = "Allows connections to ${var.service} on ${var.environment}"
  vpc_id = data.aws_subnet.selected.vpc_id


  tags = {
    Name = "${var.service}-${var.environment}-msk-connect-sg"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}

resource "aws_security_group" "msk-sg" {
  name = "${var.service}-${var.environment}-msk-sg"
  description = "MSK security group."
  vpc_id = data.aws_subnet.selected.vpc_id

  ingress {
    protocol = "tcp"
    from_port = 9092
    to_port = 9092
    cidr_blocks = [
      "0.0.0.0/0"]
    security_groups = [
      aws_security_group.connect-sg.name]
  }

  ingress {
    protocol = "tcp"
    from_port = 9094
    to_port = 9094
    cidr_blocks = [
      "0.0.0.0/0"]
    security_groups = [
      aws_security_group.connect-sg.name]
  }

  ingress {
    protocol = "tcp"
    from_port = 2181
    to_port = 2181
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
    Name = "${var.service}-${var.environment}-msk-sg"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}

resource "aws_msk_cluster" "msk" {
  cluster_name           = "${var.service}-${var.environment}-msk"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = var.number_of_broker_nodes

  broker_node_group_info {
    instance_type   = var.node_instance_type
    #ebs_volume_size = var.node_ebs_volume_size
    client_subnets = var.subnets
    security_groups = [aws_security_group.msk-sg.id]
  }

  tags = {
    Name = "${var.service}-${var.environment}-msk-cluster"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}