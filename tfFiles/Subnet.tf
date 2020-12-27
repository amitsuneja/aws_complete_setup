resource "aws_subnet" "PublicSubnetA" {
      vpc_id = aws_vpc.MyVpc.id
      cidr_block = var.PUBLIC_SUBNET_A_CIDR_BLOCK
      availability_zone = join("", [ var.AWS_REGION, "a"])
      map_public_ip_on_launch = "true"
      tags = {
            Name = "PublicSubnetA"
            Location = var.LOCATION
            Subnet = var.PUBLIC_SUBNET_A_CIDR_BLOCK
            ResourceType ="Subnet"
            EnviromentType = var.MYENVTYPE
        }
}

resource "aws_subnet" "PublicSubnetB" {
      vpc_id = aws_vpc.MyVpc.id
      cidr_block = var.PUBLIC_SUBNET_B_CIDR_BLOCK
      availability_zone = join("", [ var.AWS_REGION, "b"])
      map_public_ip_on_launch = "true"
      tags = {
            Name = "PublicSubnetB"
            Location = var.LOCATION
            Subnet = var.PUBLIC_SUBNET_B_CIDR_BLOCK
            ResourceType = "Subnet"
            EnviromentType = var.MYENVTYPE
       }
}

resource "aws_subnet" "PvtSubnetA" {
      vpc_id = aws_vpc.MyVpc.id
      cidr_block = var.PVT_SUBNET_A_CIDR_BLOCK
      availability_zone = join("", [ var.AWS_REGION, "a"])
      map_public_ip_on_launch = "false"
      tags = {
            Name = "PvtSubnetA"
            Location=var.LOCATION
            Subnet = var.PVT_SUBNET_A_CIDR_BLOCK
            ResourceType ="Subnet"
            EnviromentType = var.MYENVTYPE
      }
}

resource "aws_subnet" "PvtSubnetB" {
      vpc_id = aws_vpc.MyVpc.id
      cidr_block = var.PVT_SUBNET_B_CIDR_BLOCK
      availability_zone = join("", [ var.AWS_REGION, "b"])
      map_public_ip_on_launch = "false"
      tags = {
            Name = "PvtSubnetB"
            Location=var.LOCATION
            Subnet = var.PVT_SUBNET_B_CIDR_BLOCK
            ResourceType ="Subnet"
            EnviromentType = var.MYENVTYPE
      }
}
