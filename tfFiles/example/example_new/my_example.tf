data "template_file" "my_template" {
	 template = templatefile("${path.module}/bassion/my_template.tpl", { fruits = ["wget"]})
}
output "my_rendered" {
  value = data.template_file.my_template.template
}
