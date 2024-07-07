resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-rdssubnet"
  subnet_ids = var.subnet_ids

  tags = {
    Environment = terraform.workspace
    Name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-rdsSubnet"
    Country = var.country
    Resource = "rdsSubnet"
    Environment = terraform.workspace
    Team = var.team
    Service = var.service
  }
}


resource "aws_iam_role" "rds_role" {
  name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-RdsIamRole"

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
  tags  = {
    Environment = terraform.workspace
    Name  = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-RdsIamRole"
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
    Service = var.service  }
}

resource "aws_iam_role_policy" "rds_policy" {
  name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-RdsIamPolicy"
  role = aws_iam_role.rds_role.id

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricData"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ds:CreateComputer",
                "ds:DescribeDirectories"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogGroup",
                "logs:CreateLogStream",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "secretsmanager:CreateSecret",
                "secretsmanager:UpdateSecret",
                "secretsmanager:PutSecretValue"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_instance_profile" "rds_profile" {
  name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-RdsIamProfile"
  role = aws_iam_role.rds_role.name
}

/* Security Group for resources that want to access the Database */
resource "aws_security_group" "db_access_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-dbAccessSg"
  description = "Allow access to RDS"

  tags = {
    Environment = terraform.workspace
    Name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-dbAccessSg"
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
    Service = var.service
  }
}

resource "aws_security_group" "rds_sg" {
  name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-rdsSg"
  description = "${terraform.workspace} Security Group"
  vpc_id = var.vpc_id

  // allows traffic from the SG itself
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  //allow traffic for TCP 5432
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    security_groups = [aws_security_group.db_access_sg.id]
  }

  //allow traffic for TCP 5432
  ingress {
    from_port = 5432
    to_port   = 5432
    protocol  = "tcp"
    cidr_blocks = var.sg_cidr_blocks
  }

  // outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = terraform.workspace
    Name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-rdsSg"
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
    Service = var.service
  }
}

resource "random_string" "rds_password" {
  length = 16
  special = true
}

resource "aws_secretsmanager_secret" "rds_secret" {
  name  = "${var.country}/${var.team}/${terraform.workspace}/${var.name}/app/rds"
  recovery_window_in_days = 0
  tags  = {
    Environment = terraform.workspace
    Name  = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-RdsSecret"
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team  }
}

resource "aws_db_parameter_group" "rds_parameters" {
  name   = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-dbparametergroup"
  family = "postgres12"

  parameter {
    name  = "log_statement"
    value = "all"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1"
  }

  lifecycle {
    create_before_destroy = true
  }
}

locals {
  db_identifier = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-rdsdatabase"
}

#Get latest RDS snapshot
data "aws_db_snapshot" "db_snapshot" {
  most_recent            = true
  db_instance_identifier = local.db_identifier
}

resource "aws_db_instance" "rds" {
  identifier             = local.db_identifier
  final_snapshot_identifier = "${lower(local.db_identifier)}-final-${md5(timestamp())}"
  snapshot_identifier       = data.aws_db_snapshot.db_snapshot.id
  allocated_storage      = var.allocated_storage
  storage_type            = "gp2"
  engine                 = "postgres"
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  multi_az               = var.multi_az
  #name                   = var.database_name
  username               = var.database_username
  password               = sha1(bcrypt(random_string.rds_password.result))
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = false
  maintenance_window      = "Sat:03:00-Sat:05:00"
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible     = false
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  enabled_cloudwatch_logs_exports = var.logfiles
  parameter_group_name    = aws_db_parameter_group.rds_parameters.name
  apply_immediately = true
  availability_zone = var.availability_zone
  ca_cert_identifier = var.rds_cert
  kms_key_id = var.kms_key
  storage_encrypted = true

  provisioner "local-exec" {
    command = "DBPASS=$(openssl rand -base64 10) && SECRET_STRING=$(jq -n '{\"host\": \"${var.hostname}\",\"username\": \"${aws_db_instance.rds.username}\",\"password\": \"'\"$DBPASS\"'\",\"port\": \"5432\"}') && aws rds modify-db-instance --db-instance-identifier ${self.id} --master-user-password $DBPASS --apply-immediately && aws secretsmanager put-secret-value --secret-id ${aws_secretsmanager_secret.rds_secret.id} --secret-string \"$SECRET_STRING\""
  }

  lifecycle {
    ignore_changes = ["password", "snapshot_identifier"]
  }

  tags = {
    Environment = terraform.workspace
    Name = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-rdsDatabase"
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
    Backup = "${var.country}-${var.team}-${terraform.workspace}"
    Service = var.service
  }
}

resource "aws_route53_record" "rds_route53" {
  zone_id = var.route53_zone_id
  name = var.hostname
  type = "CNAME"
  ttl = 180
  records = [aws_db_instance.rds.address]
}


// CPU Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "cpu_utilization_too_high" {
  count       = var.cpu_alarm_active == true ? 1 : 0
  alarm_name          = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-highCPUUtilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "CPUUtilization"
  namespace           = "AWS/RDS"
  period              = var.alarm_statistic_period
  statistic           = "Average"
  threshold           = var.cpu_utilization_too_high_threshold
  alarm_description   = "Average database CPU utilization is too high."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds.id
  }
  tags = {
    Environment = terraform.workspace
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
  }
}

resource "aws_cloudwatch_metric_alarm" "cpu_credit_balance_too_low" {
  count               = length(regexall("(t2|t3)", var.instance_class)) > 0 && var.cpu_alarm_active == true ? "1" : "0"
  alarm_name          = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-lowCPUCreditBalance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "CPUCreditBalance"
  namespace           = "AWS/RDS"
  period              = var.alarm_statistic_period
  statistic           = "Average"
  threshold           = var.cpu_credit_balance_too_low_threshold
  alarm_description   = "Average database CPU credit balance is too low, a negative performance impact is imminent."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds.id
    DBInstanceIdentifier = aws_db_instance.rds.id
  }
  tags = {
    Environment = terraform.workspace
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
  }
}

// Disk Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "disk_queue_depth_too_high" {
  count       = var.disk_alarm_active == true ? 1 : 0
  alarm_name          = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-highDiskQueueDepth"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "DiskQueueDepth"
  namespace           = "AWS/RDS"
  period              = var.alarm_statistic_period
  statistic           = "Average"
  threshold           = var.disk_queue_depth_too_high_threshold
  alarm_description   = "Average database disk queue depth is too high, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds.id
  }
  tags = {
    Environment = terraform.workspace
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_free_storage_space_too_low" {
  count       = var.disk_alarm_active == true ? 1 : 0
  alarm_name          = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-lowFreeStorageSpace"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "FreeStorageSpace"
  namespace           = "AWS/RDS"
  period              = var.alarm_statistic_period
  statistic           = "Average"
  threshold           = var.disk_free_storage_space_too_low_threshold
  alarm_description   = "Average database free storage space is too low and may fill up soon."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds.id
  }
  tags = {
    Environment = terraform.workspace
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
  }
}

resource "aws_cloudwatch_metric_alarm" "disk_burst_balance_too_low" {
  count       = var.disk_alarm_active == true ? 1 : 0
  alarm_name          = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-lowEBSBurstBalance"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "BurstBalance"
  namespace           = "AWS/RDS"
  period              = var.alarm_statistic_period
  statistic           = "Average"
  threshold           = var.disk_burst_balance_too_low_threshold
  alarm_description   = "Average database storage burst balance is too low, a negative performance impact is imminent."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds.id
  }
  tags = {
    Environment = terraform.workspace
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
  }
}

// Memory Utilization Alarm
resource "aws_cloudwatch_metric_alarm" "memory_freeable_too_low" {
  count       = var.memory_alarm_active == true ? 1 : 0
  alarm_name          = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-lowFreeableMemory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "FreeableMemory"
  namespace           = "AWS/RDS"
  period              = var.alarm_statistic_period
  statistic           = "Average"
  threshold           = var.memory_freeable_too_low_threshold
  alarm_description   = "Average database freeable memory is too low, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds.id
  }
  tags = {
    Environment = terraform.workspace
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_swap_usage_too_high" {
  count       = var.memory_alarm_active == true ? 1 : 0
  alarm_name          = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-highSwapUsage"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  metric_name         = "SwapUsage"
  namespace           = "AWS/RDS"
  period              = var.alarm_statistic_period
  statistic           = "Average"
  threshold           = var.memory_swap_usage_too_high_threshold
  alarm_description   = "Average database swap usage is too high, performance may be negatively impacted."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.rds.id
  }
  tags = {
    Environment = terraform.workspace
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
  }
}

// Connection Count Alarm
resource "aws_cloudwatch_metric_alarm" "connection_count_anomalous" {
  count       = var.connection_count_alarm_active == true ? 1 : 0
  alarm_name          = "${var.country}-${var.team}-${terraform.workspace}-${var.service}-anomalousConnectionCount"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = var.alarm_evaluation_period
  threshold_metric_id = "e1"
  alarm_description   = "Anomalous database connection count detected. Something unusual is happening."
  alarm_actions       = var.actions_alarm
  ok_actions          = var.actions_ok

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, ${var.alarm_anomaly_band_width})"
    label       = "DatabaseConnections (Expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "DatabaseConnections"
      namespace   = "AWS/RDS"
      period      = var.alarm_anomaly_period
      stat        = "Average"
      unit        = "Count"

      dimensions = {
        DBInstanceIdentifier = aws_db_instance.rds.id
      }
    }
  }
  tags = {
    Environment = terraform.workspace
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
  }
}