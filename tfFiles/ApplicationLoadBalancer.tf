# Create A Load Balancer
resource "aws_alb" "WebServer-load-balancer" {
    depends_on = [aws_volume_attachment.Attach-SlaveDB-Datavol0001,aws_volume_attachment.Attach-SlaveDB-Datavol0002]
    name                = "WebServer-load-balancer"
    internal            = false
    subnets             = [aws_subnet.PublicSubnetA.id,aws_subnet.PublicSubnetB.id]
    security_groups     = [aws_security_group.LoadBalancerSG.id]
    enable_deletion_protection = "false"
    tags = {
      Name = "WebServer-load-balancer"
    }
}

# Create Target Group
resource "aws_alb_target_group" "WebServer-target-group" {
    depends_on = [aws_volume_attachment.Attach-SlaveDB-Datavol0001,aws_volume_attachment.Attach-SlaveDB-Datavol0002]
    name                = "WebServer-target-group"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = aws_vpc.MyVpc.id
    health_check {
        healthy_threshold   = "3"
        unhealthy_threshold = "2"
        interval            = "10"
        matcher             = "200"
        path                = "/index.html"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }
    tags = {Name = "WebServer-target-group"}
}

# Create Listner in Load Balancer : Listner connects your LoadBalancer to Target Group.
#
#resource "aws_lb_listener" "alb-listener" {
#    depends_on = [aws_volume_attachment.Attach-SlaveDB-Datavol0001,aws_volume_attachment.Attach-SlaveDB-Datavol0002]
#    load_balancer_arn = aws_alb.WebServer-load-balancer.arn
#    port              = "80"
#    protocol          = "HTTP"
#    default_action { 
#        type             = forward
#				  forward {
#      					target_group {
#        					arn    = aws_alb_target_group.WebServer-target-group.arn
#        					weight = 250
#     					}	
#                                  }
#        #target_group_arn = aws_alb_target_group.WebServer-target-group.arn
#    }
#}
