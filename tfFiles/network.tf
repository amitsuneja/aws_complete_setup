resource "aws_vpc" "MyVpc" {
     cidr_block              = var.VPC_CIDR_BLOCK
     enable_dns_hostnames    = var.ENABLE_DNS_HOSTNAMES
     enable_dns_support      = var.ENABLE_DNS_SUPPORT
         tags = {
            Name = "MyVpc"
            Location= var.LOCATION
            CIDR_Block = var.VPC_CIDR_BLOCK
            ResourceType ="VPC"
     }
}
