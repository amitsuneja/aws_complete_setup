###############################################Routing Table for Private Subnet############################
resource "aws_route_table" "PvtSub-RT" {
      vpc_id  = aws_vpc.MyVpc.id
      tags = { Name ="PvtSub-RT" }
      depends_on = [aws_instance.BasionHost]
      route {
             cidr_block = "0.0.0.0/0"
             instance_id = aws_instance.BasionHost.id
            }
}
###############################################Associate Private Subnets with PVT route table
resource "aws_route_table_association" "PvtSub-RT-Association_A" {
       subnet_id      = aws_subnet.PvtSubnetA.id
       route_table_id = aws_route_table.PvtSub-RT.id
}
resource "aws_route_table_association" "PvtSub-RT-Association_B" {
       subnet_id      = aws_subnet.PvtSubnetB.id
       route_table_id = aws_route_table.PvtSub-RT.id
}
