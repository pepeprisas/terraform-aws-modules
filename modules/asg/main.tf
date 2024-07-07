resource "aws_placement_group" "asg-placement-group" {
  name = "${var.service}-${var.environment}-placement-group"
  strategy = "cluster"

  tags = {
    Name = "${var.service}-${var.environment}-placement-group"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }

}

resource "aws_launch_template" "asg-launch-template" {
  name = "${var.service}-${var.environment}-launch-template"
  image_id = var.ec2-ami
  instance_type = var.instance-type
  user_data = filebase64(var.user-data)
  
   tags = {
    Name = "${var.service}-${var.environment}-launch-template"
    Service = var.service
    Environment = var.environment
    Team = var.team
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${var.service}-${var.environment}-asg"
  availability_zones = [var.subnet-id]
  min_size = var.min-size
  desired_capacity = var.starting-size
  max_size = var.min-size
  health_check_type = var.health-check-type
  target_group_arns = [var.alb-arn]


  launch_template {
    id = aws_launch_template.asg-launch-template.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "asg-autoscalling-policy" {
  name = "${var.service}-${var.environment}-autoscalling-policy"
  cooldown = var.cooldown
  policy_type = "TargetTrackingScaling"
  estimated_instance_warmup = var.instance-warmup
  autoscaling_group_name = aws_autoscaling_group.asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = var.target-meassurement
    }

    target_value = var.target-value
  }
}
