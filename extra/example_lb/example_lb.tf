provider "aws" {
  version = "~> v2.69.0"
  region  = "us-east-1"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "=v2.44.0"

  name = "tf-test"

  cidr            = "10.59.0.0/16"
  public_subnets  = ["10.59.0.0/20"]
  private_subnets = ["10.59.48.0/20","10.59.64.0/20"]

  azs = ["us-east-1a","us-east-1b"]
}

resource "aws_security_group" "allow_www" {
  name        = "alb-allow-www"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTP from the Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_lb" "test" {
  name               = "test-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.allow_www.id]
  subnets            = module.vpc.private_subnets
}

resource "aws_lb_target_group" "test-big" {
  name        = "test-big"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    protocol = "HTTP"
    port     = 80
    path     = "/healthcheck"
  }
}

resource "aws_lb_target_group_attachment" "test-big" {
  port              = 80
  target_id         = "10.1.1.1"
  target_group_arn  = aws_lb_target_group.test-big.arn
  availability_zone = "all"
}

resource "aws_lb_target_group" "test-small" {
  name        = "test-small"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = module.vpc.vpc_id

  health_check {
    protocol = "HTTP"
    port     = 80
    path     = "/healthcheck"
  }
}

resource "aws_lb_target_group_attachment" "test-small" {
  port              = 80
  target_id         = "10.1.1.2"
  target_group_arn  = aws_lb_target_group.test-small.arn
  availability_zone = "all"
}

resource "aws_lb_listener" "test-http-listener" {
  load_balancer_arn = aws_lb.test.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    forward {
      target_group {
        arn    = aws_lb_target_group.test-big.arn
        weight = 250
      }
      target_group {
        arn    = aws_lb_target_group.test-small.arn
        weight = 80
      }
    }
  }
}
