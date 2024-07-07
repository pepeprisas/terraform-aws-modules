resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-rds-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Environment = terraform.workspace
    Name = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-rds-subnet-group"
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
  }
}

resource "aws_iam_role" "mariadb_role" {
  name = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-iam-role"

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
    Name  = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-iam-role"
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team  }
}

resource "aws_iam_role_policy" "mariadb_policy" {
  name = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-iam-policy"
  role = aws_iam_role.mariadb_role.id

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

resource "aws_iam_instance_profile" "mariadb_profile" {
  name = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-iam-profile"
  role = aws_iam_role.mariadb_role.name
}

/* Security Group for resources that want to access the Database */
resource "aws_security_group" "db_access_sg" {
  vpc_id      = var.vpc_id
  name        = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-db-access-sg"
  description = "Allow access to RDS"

  tags = {
    Environment = terraform.workspace
    Name = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-db-access-sg"
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
  }
}

resource "aws_security_group" "mariadb_sg" {
  name = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-rds-sg"
  description = "${terraform.workspace} Security Group"
  vpc_id = var.vpc_id

  // allows traffic from the SG itself
  ingress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    self = true
  }

  //allow traffic for TCP 3306
  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "tcp"
    security_groups = [aws_security_group.db_access_sg.id]
  }

  //allow traffic for TCP 3306
  ingress {
    from_port = 3306
    to_port   = 3306
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
    Name = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-rds-sg"
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team
  }
}

resource "aws_db_parameter_group" "mariadb_pg" {
  name   = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-db-parameter-group"
  family = "mariadb10.3"

  parameter {
    name  = "character_set_client"
    value = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "character_set_connection"
    value = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "character_set_database"
    value = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "character_set_results"
    value = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "character_set_server"
    value = "utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "collation_connection"
    value = "utf8mb4_unicode_ci"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "collation_server"
    value = "utf8mb4_unicode_ci"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "event_scheduler"
    value = "OFF"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "general_log"
    value = "0"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "init_connect"
    value = "SET NAMES utf8mb4"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "join_buffer_size"
    value = "512000"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "key_buffer_size"
    value = "8388608"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "log_output"
    value = "FILE"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "query_cache_limit"
    value = "10000000"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "query_cache_min_res_unit"
    value = "12000"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "query_cache_size"
    value = "32000000"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "query_cache_type"
    value = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "slow_query_log"
    value = "1"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "sort_buffer_size"
    value = "512000"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "table_open_cache"
    value = "2000"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "thread_cache_size"
    value = "100"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "max_allowed_packet"
    value = "1073741824"
    apply_method = "pending-reboot"
  }

  parameter {
    name  = "wait_timeout"
    value = "2592100"
    apply_method = "pending-reboot"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags  = {
    Environment = terraform.workspace
    Name  = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-db-parameter-group"
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team  }
}

resource "random_string" "mariadb_password" {
  length = 16
  special = true
}

resource "aws_secretsmanager_secret" "mariadb_secret" {
  name  = "${var.country}/${terraform.workspace}/${var.name}/app/rds"
  tags  = {
    Environment = terraform.workspace
    Name  = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-secret"
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team  }
}

resource "aws_db_instance" "mariadb" {
  identifier              = var.identifier
  allocated_storage       = var.allocated_storage
  storage_type            = "gp2"
  engine                  = "mariadb"
  engine_version          = var.engine_version
  instance_class          = var.instance_class
  #name                    = var.name
  username                = var.database_username
  password                = sha1(bcrypt(random_string.mariadb_password.result))
  vpc_security_group_ids = [aws_security_group.mariadb_sg.id]
  multi_az                = var.multi_az
  skip_final_snapshot     = true
  backup_retention_period = 90
  parameter_group_name    = aws_db_parameter_group.mariadb_pg.name
  backup_window           = "02:00-03:00"
  maintenance_window      = "Fri:03:00-Fri:05:00"
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  publicly_accessible     = false
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = false
  enabled_cloudwatch_logs_exports = var.logfiles
  apply_immediately = true
  availability_zone = var.availability_zone
  ca_cert_identifier = "rds-ca-2019"
  kms_key_id = var.kms_key

  tags  = {
    Environment = terraform.workspace
    Name  = "${var.country}-${var.team}-${terraform.workspace}-${var.name}-${var.resource}"
    Country = var.country
    Resource = var.resource
    Environment = terraform.workspace
    Team = var.team  }

  provisioner "local-exec" {
    command = "DBPASS=$(openssl rand -base64 10) && SECRET_STRING=$(jq -n '{\"host\": \"${var.hostname}\",\"username\": \"${aws_db_instance.mariadb.username}\",\"password\": \"'\"$DBPASS\"'\",\"port\": \"${aws_db_instance.mariadb.port}\"}') && aws rds modify-db-instance --db-instance-identifier ${self.id} --master-user-password $DBPASS --apply-immediately && aws secretsmanager put-secret-value --secret-id ${aws_secretsmanager_secret.mariadb_secret.id} --secret-string \"$SECRET_STRING\""
  }

  lifecycle {
    ignore_changes = ["password"]
  }
}

resource "aws_route53_record" "rds_route53" {
  zone_id = var.route53_zone_id
  name = var.hostname
  type = "CNAME"
  ttl = 180
  records = [aws_db_instance.mariadb.address]
}