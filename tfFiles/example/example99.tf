data "template_file" "example99" {
     template = templatefile("${path.module}/config99.tpl", {
                 config = {
                   "x"   = "y"
                   "foo" = "bar"
                   "key" = "value"
                 }
               })
}

output "rendered99" {
  value = data.template_file.example99.template
}
