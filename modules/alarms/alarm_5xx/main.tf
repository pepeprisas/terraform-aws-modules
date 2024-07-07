
provider "aws" { region = var.region }

resource "aws_cloudwatch_metric_alarm" "target-metric-5xx" {
    alarm_name  = var.alarm_name
    comparison_operator = var.comparison_operator
    period = var.period
    statistic  =  var.statistic
    threshold =   var.threshold
    evaluation_periods = var.evaluation_periods    
    metric_name         =  var.metric_name
    namespace           =  var.namespace
    alarm_description   =  var.alarm_description
    alarm_actions       =  ["arn:aws:sns:${var.region}:${var.account}:${var.user_sns}"]
    ok_actions          =  ["arn:aws:sns:${var.region}:${var.account}:${var.user_sns}"]
    #insufficient_data_actions = [var.alarm_sns[terraform.workspace]]
    dimensions = { 
      LoadBalancer = var.LoadBalancerName
    }
    treat_missing_data = var.treat_missing_data
    unit        = "Count"
    tags = {
        Name = "${var.country}-${var.team}-${terraform.workspace}-${var.resource}-${var.service}-${var.metric_name}"
        Country = var.country
        Team = var.team
        Environment = terraform.workspace
        Resource = var.resource
    }
}