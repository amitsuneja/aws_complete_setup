output "aws_ips" {
  value = aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses
}
