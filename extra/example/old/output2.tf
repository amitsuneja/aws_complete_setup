data "aws_vpc_dhcp_options" "foo" {
  tags = {
           Name = "DhcpOptionforAD"
           DomainName = var.DOMAINNAME
	 }
}

output "foo" {
  value = data.aws_vpc_dhcp_options.foo.domain_name_servers
}
