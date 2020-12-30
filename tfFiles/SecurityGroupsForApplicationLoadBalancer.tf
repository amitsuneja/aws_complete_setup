resource "aws_security_group" "LoadBalancerSG" {

      vpc_id  = aws_vpc.MyVpc.id
      name    = "LB_SG"
      description = "This security group is for Application Load Balancer"
      tags    = {Name ="LoadBalancerSG",location = var.LOCATION}


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
