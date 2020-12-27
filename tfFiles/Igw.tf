resource "aws_internet_gateway" "IGW" {
      vpc_id = aws_vpc.MyVpc.id
         tags = {
            Name = "IGW"
            ResourceType = "InternetGateway"
            Location     = var.LOCATION
       }
}
