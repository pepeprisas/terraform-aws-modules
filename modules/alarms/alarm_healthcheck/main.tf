resource "aws_cloudwatch_metric_alarm" "instance_status_check" {
    alarm_name                =  "${var.country}-${var.team}-${terraform.workspace}-${var.resource}-${var.name}"
    alarm_description         =  var.description 
    metric_name               =  var.metric_name
    namespace                 =  var.namespace
    statistic                 =  var.statistic
    dimensions = { 
        InstanceId = var.instance_id
    }
    unit                      =  var.unit
    period                    =  var.period
    evaluation_periods        =  var.evaluation_periods
    threshold                 =  var.threshold
    comparison_operator       =  var.comparison_operator
    alarm_actions             =  ["arn:aws:sns:${var.region}:968479493337:${var.sns_topic}"]
    ok_actions                =  ["arn:aws:sns:${var.region}:968479493337:${var.sns_topic}"]
    insufficient_data_actions =  ["arn:aws:sns:${var.region}:968479493337:${var.sns_topic}"]
    datapoints_to_alarm       =  var.datapoints_to_alarm
    treat_missing_data        =  var.treat_missing_data
    
    tags = {
        Name        = "${var.country}-${var.team}-${terraform.workspace}-${var.resource}-${var.name}"
        Country     = var.country
        Team        = var.team
        Environment = terraform.workspace
        Resource    = var.resource
    }
}
