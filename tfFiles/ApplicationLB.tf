resource "aws_security_group" "LoadBalancerSG" {
      vpc_id  = aws_vpc.MyVpc.id
      name    = "LB_SG"
      tags    = { Name ="LoadBalancerSG",
                  location = var.LOCATION
      }


  ingress {
    protocol  = "-1"
    self      = true
    from_port = 0
    to_port   = 0
    description = "Allow all the traffic with in Security Group"
  }

  ingress {
    protocol  = "tcp"
    from_port = 80
    to_port   = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow http from world"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Alow all the traffic to go out , -1 means all protocols"
  }
}



resource "aws_alb" "WebServer-load-balancer" {
       depends_on = [aws_volume_attachment.Attach-SlaveDB-Datavol0002]

    name                = "WebServer-load-balancer"
    internal            = false
    subnets             = [aws_subnet.PublicSubnetA.id,aws_subnet.PublicSubnetB.id]
    security_groups     = [aws_security_group.LoadBalancerSG.id]
    enable_deletion_protection = "false"
    tags = {
      Name = "WebServer-load-balancer"
    }
}

resource "aws_alb_target_group" "WebServer-target-group" {
       depends_on = [aws_volume_attachment.Attach-SlaveDB-Datavol0002]

    name                = "WebServer-target-group"
    port                = "80"
    protocol            = "HTTP"
    vpc_id              = aws_vpc.MyVpc.id


    health_check  {
        healthy_threshold   = "3"
        unhealthy_threshold = "2"
        interval            = "10"
        matcher             = "200"
        path                = "/index.html"
        port                = "traffic-port"
        protocol            = "HTTP"
        timeout             = "5"
    }

    tags = {
      Name = "WebServer-target-group"
    }
}

resource "aws_alb_listener" "alb-listener" {
       depends_on = [aws_volume_attachment.Attach-SlaveDB-Datavol0002]

    load_balancer_arn = aws_alb.WebServer-load-balancer.arn
    port              = "80"
    protocol          = "HTTP"

    default_action {
        target_group_arn = aws_alb_target_group.WebServer-target-group.arn
        type             = "forward"
    }
}
