data "aws_caller_identity" "current" {}
data "template_file" "policy" {
  template = "${file(var.policydata)}"
}
data "aws_subnet" "selected" {
  id = var.subnet_id
}
data "aws_instance" "master" {
  depends_on = [aws_emr_cluster.cluster]
  filter {
    name   = "tag:Name"
    values = ["${aws_emr_cluster.cluster.name}"]
  }
  filter {
    name   = "tag:aws:elasticmapreduce:instance-group-role"
    values = ["MASTER"]
  }
}
resource "aws_security_group" "sg" {
  name        = "${terraform.workspace}-${var.service}-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = data.aws_subnet.selected.vpc_id
  ingress {
    description = "TLS from IP"
    from_port   = 22
    to_port     = 8787
    protocol    = "tcp"
    cidr_blocks = ["10.9.0.0/16"]   ###### To change
  }
  ingress {
    description     = "TLS from VPC"
    from_port       = 22
    to_port         = 8787
    protocol        = "tcp"
    security_groups = var.sg
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name        = "${terraform.workspace}-${var.service}-sg"
    Resource    = "sg"
    Environment = terraform.workspace
    Service     = var.service
  }
}
resource "aws_iam_role" "roleemr" {
  name               = "${terraform.workspace}-${var.service}-roleEmr"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    Name        = "${terraform.workspace}-${var.service}-roleEmr"
    Resource    = "role"
    Environment = terraform.workspace
    Service     = var.service
  }
}
resource "aws_iam_role" "roleemrautoscaling" {
  name               = "${terraform.workspace}-${var.service}-roleemrAutoscaling"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
     {
      "Effect": "Allow",
      "Principal": {
        "Service": [
          "application-autoscaling.amazonaws.com",
          "elasticmapreduce.amazonaws.com"
        ]
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
  tags = {
    Name        = "${terraform.workspace}-${var.service}-roleEmrAutoscaling"
    Resource    = "role"
    Environment = terraform.workspace
    Service     = var.service
  }
}
resource "aws_iam_role_policy" "role_policy" {
  name   = "${terraform.workspace}-${var.service}-policyEmrAutoscaling"
  role   = aws_iam_role.roleemr.id
  policy = data.template_file.policy.template
}
resource "aws_iam_role_policy" "role_policyautoscaling" {
  name   = "${terraform.workspace}-${var.service}-policyEmrAutoscaling"
  role   = aws_iam_role.roleemrautoscaling.id
  policy = data.template_file.policy.template
}
resource "aws_iam_instance_profile" "profileemr" {
  name = "${terraform.workspace}-${var.service}-profileEmr"
  role = aws_iam_role.roleemr.name
}
resource "aws_emr_cluster" "cluster" {
  name                              = "${terraform.workspace}-${var.service}-emrCluster"
  release_label                     = "emr-6.1.0"
  applications                      = var.applications
  additional_info                   = <<EOF
{
  "instanceAwsClientConfiguration": {
    "proxyPort": 8099,
    "proxyHost": "myproxy.example.com"
  }
}
EOF
  termination_protection            = false
  keep_job_flow_alive_when_no_steps = true
  ec2_attributes {
    subnet_id                         = var.subnet_id
    emr_managed_master_security_group = var.sg[0]
    emr_managed_slave_security_group  = var.sg[0]
    instance_profile                  = aws_iam_instance_profile.profileemr.arn
  }
  master_instance_group {
    instance_type = var.masterec2type
  }
  core_instance_group {
    instance_type  = var.clusterec2type
    instance_count = 1
    ebs_config {
      size                 = "40"
      type                 = "gp2"
      volumes_per_instance = 1
    }
    bid_price = var.bid_price
    #     autoscaling_policy = <<EOF
    # {
    # "Constraints": {
    #   "MinCapacity": 1,
    #   "MaxCapacity": 2
    # },
    # "Rules": [
    #   {
    #     "Name": "ScaleOutMemoryPercentage",
    #     "Description": "Scale out if YARNMemoryAvailablePercentage is less than 15",
    #     "Action": {
    #       "SimpleScalingPolicyConfiguration": {
    #         "AdjustmentType": "CHANGE_IN_CAPACITY",
    #         "ScalingAdjustment": 1,
    #         "CoolDown": 300
    #       }
    #     },
    #     "Trigger": {
    #       "CloudWatchAlarmDefinition": {
    #         "ComparisonOperator": "LESS_THAN",
    #         "EvaluationPeriods": 1,
    #         "MetricName": "YARNMemoryAvailablePercentage",
    #         "Namespace": "AWS/ElasticMapReduce",
    #         "Period": 300,
    #         "Statistic": "AVERAGE",
    #         "Threshold": 15.0,
    #         "Unit": "PERCENT"
    #       }
    #     }
    #   }
    # ]
    # }
    # EOF
  }
  ebs_root_volume_size = 100
  tags = {
    Name        = "${terraform.workspace}-${var.service}-emrCluster"
    Resource    = "emrCluster"
    Environment = terraform.workspace
    Service     = var.service
  }
  bootstrap_action {
    path = "s3://${var.s3emr}/users/users.sh"
    name = "users.sh"
    args = ["instance.isMaster=true", "${var.efs_id}", "${terraform.workspace}-${var.service}-roleEmr", "${var.s3emr}"]
  }
  configurations_json = "${file(var.configurationemr)}"
  service_role        = aws_iam_role.roleemrautoscaling.arn
}