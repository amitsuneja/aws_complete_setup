resource "aws_default_security_group" "default" {
      vpc_id  = aws_vpc.MyVpc.id
         tags = { 
                Name ="DefaultSG"
                Location = var.LOCATION
                ResourceType = "SecurityGroup"
          }

  ingress {
    protocol  = "tcp"
    from_port = 22
    to_port   = 22
    cidr_blocks = var.HOMEIPADDRESS
    description = "Allow ssh from home"
  }

  ingress {
    protocol  = "tcp"
    from_port = 3389
    to_port   = 3389
    cidr_blocks = var.HOMEIPADDRESS
    description = "Allow RDP from home"
  }

  ingress {
    protocol  = "tcp"
    from_port = 5985
    to_port   = 5985
    cidr_blocks = var.HOMEIPADDRESS
    description = "Allow WMRI over http"
  }

  ingress {
    protocol  = "tcp"
    from_port = 5986
    to_port   = 5986
    cidr_blocks = var.HOMEIPADDRESS
    description = "Allow WMRI over https"
  }


  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = [var.VPC_CIDR_BLOCK]
   }


  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Alow all the traffic to go out , -1 means all protocols"
  }
}


resource "aws_security_group" "BE_SG" {
  name        = "BE_SG"
  description = "Allow all inbound traffic"
  vpc_id  = aws_vpc.MyVpc.id
     tags = { 
             Name ="BE_SG" 
             Location = var.LOCATION
             ResourceType = "SecurityGroup"
     }

  ingress {
    protocol  = "-1"
    from_port = 0
    to_port   = 0
    cidr_blocks = [var.VPC_CIDR_BLOCK]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
   protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
