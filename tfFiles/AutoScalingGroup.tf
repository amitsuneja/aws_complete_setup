resource "aws_autoscaling_group" "Webserver-autoscaling-group" {
       depends_on = [aws_alb_listener.alb-listener,aws_launch_configuration.WebServer-launch-configuration]
       name                        = "WebServer-autoscaling-group"
       max_size                    = 6
       min_size                    = 0
       desired_capacity            = 0
       health_check_type           = "ELB"
       target_group_arns           = [aws_alb_target_group.WebServer-target-group.arn]
       health_check_grace_period   = 300
       vpc_zone_identifier         = [aws_subnet.PublicSubnetA.id,aws_subnet.PublicSubnetB.id]
       launch_configuration        = aws_launch_configuration.WebServer-launch-configuration.name
  }
