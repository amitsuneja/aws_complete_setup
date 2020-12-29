variable "foo" {
  type = list
  default = [ 1,2,3 ]
}

output "aws_ips" {
  value = aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses
}
output "dns_ip" {
  value = [var.DNSSERVERFORVPC]
}
output "dns_ip1" {
  value = list(var.DNSSERVERFORVPC)
}
output "bar_type" {
  value = concat(list(var.DNSSERVERFORVPC),var.foo, [4])
}
output "bar_typei1" {
  value = list(aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses)
}
