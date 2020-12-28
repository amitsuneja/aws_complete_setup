#locals {
#  AdFirstIp = sort(aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses)[0]
#  AdSeconfIp = sort(aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses)[0]
#}




output "aws_ActiveDirectory_IP_0" {
  value = local.AdFirstIp
}

output "aws_ActiveDirectory_IP_1" {
  value = local.AdSecondIp
}
