data "template_file" "hello" {
  template = file("hello.tpl")
  vars     = {
    name = "world"
  }
}

output "hello" {
  value = data.template_file.hello.rendered
}
