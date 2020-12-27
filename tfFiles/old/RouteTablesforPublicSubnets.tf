resource "aws_default_route_table" "default_routing" {
      default_route_table_id = aws_vpc.MyVpc.default_route_table_id
   
      tags = { 
             Name         = "DefauultRouteTable"
             Location     = var.LOCATION
             ResourceType = "RoutingTable"
      }
}


resource "aws_route_table" "PublicSubnet-RT" {
      vpc_id            = aws_vpc.MyVpc.id
      depends_on        = [aws_internet_gateway.IGW]
      route {
             cidr_block = "0.0.0.0/0"
             gateway_id = aws_internet_gateway.IGW.id
      }

      tags = { 
             Name         = "PublicSubnet-RT"
             Location     = var.LOCATION
             ResourceType = "RoutingTable"
      }
}

resource "aws_route_table_association" "PublicSubnetA-RT-Association" {
       subnet_id        = aws_subnet.PublicSubnetA.id
       route_table_id   = aws_route_table.PublicSubnet-RT.id
}

resource "aws_route_table_association" "PublicSubnetB-RT-Association" {
       subnet_id        = aws_subnet.PublicSubnetB.id
       route_table_id   = aws_route_table.PublicSubnet-RT.id
}
