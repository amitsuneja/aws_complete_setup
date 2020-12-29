# Note:- this will also create 2 network interfaces, that requirment of Active Directory.


resource "aws_directory_service_directory" "MyActiveDirectory" {
       name       = var.DOMAINNAME
       password   = var.DOMAINADMINPASSWORD
       size       = var.DOMAINSIZE
       
        vpc_settings {
            vpc_id     = aws_vpc.MyVpc.id
            subnet_ids = [aws_subnet.PvtSubnetA.id,aws_subnet.PvtSubnetB.id]
          } 

         tags =  { 
            DomainName   = var.DOMAINNAME
            Location     = var.LOCATION
            ResourceType = "ActiveDirectory"
            SizeOfAD     = var.DOMAINSIZE
          }
}
