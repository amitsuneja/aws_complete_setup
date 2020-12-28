output "aws_ActiveDirectory_IP" {
  value = aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses
}
output "aws_var_IP" {
  value = [var.DNSSERVERFORVPC]
}
output "aws_ActiveDirectory_var_IP"{
 value = [join(",",aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses,[var.DNSSERVERFORVPC])]
}
output "count_number_of_elements"{
  value = length(aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses)
}
output "aws_var_ActiveDirectory_IP"{
 value = [join(",",[var.DNSSERVERFORVPC],aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses)]
}

