# Alarm EC2 instances health checks
Create a alarm based on EC2 system and instance checks
https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/monitoring-system-instance-status-check.html

Dimensions

    InstanceId


### Example 

```
data "aws_instance" "ec2_server-main" {
  filter {
    name = "tag:Name"
    values = ["server-main"]
  }
}

module "alarm_healthcheck_server-main" {
  source              = "git::ssh://git@github.com/${var.githubproject}.git//modules/alarms/alarm_healthcheck"
  region              = var.region
  name                = "server-main-StatusCheck"
  description         = "Status check for main server"
  resource            = "ec2"
  team                = var.team
  country             = var.country
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  statistic           = "Maximum"
  instance_id         = "${data.aws_instance.ec2_server-main.id}"
  unit                = "Count"
  period              = 300
  evaluation_periods  = 1
  threshold           = 1
  datapoints_to_alarm = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  sns_topic           = "ehread"
  treat_missing_data  = "breaching"
}
```