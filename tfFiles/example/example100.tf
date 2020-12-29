data "template_file" "example" {
     template = templatefile("${path.module}/backends100.tpl", { port = 8080, ip_addrs = ["10.0.0.1", "10.0.0.2"] })
}

output "rendered" {
  value = data.template_file.example.template
}
