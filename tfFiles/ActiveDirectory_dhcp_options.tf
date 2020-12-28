resource "aws_vpc_dhcp_options" "DhcpOptionforAD" {
 domain_name          = var.DOMAINNAME
 #domain_name_servers=[join(",",aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses,[var.DNSSERVERFORVPC])]
 domain_name_servers=[join(",",[var.DNSSERVERFORVPC],aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses)]
 ntp_servers          = aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses
 netbios_name_servers = aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses
  tags = {
                  Name = "DhcpOptionforAD"
            DomainName = var.DOMAINNAME
        }
}


resource "aws_vpc_dhcp_options_association" "dns_resolver" {
    vpc_id     = aws_vpc.MyVpc.id
    dhcp_options_id = aws_vpc_dhcp_options.DhcpOptionforAD.id
}

resource "aws_default_vpc_dhcp_options" "default" {
  tags = {
    Name = "DhcpOptionDefault-donotuse"
  }
}
