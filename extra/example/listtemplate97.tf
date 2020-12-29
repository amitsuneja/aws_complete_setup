locals {
  fruits = ["apple", "banana", "pear"]
}

output "fruits" {
  value = <<-EOF
    My favourite fruits are:
    %{ for fruit in local.fruits ~}
  - ${ fruit }
    %{ endfor ~}
  EOF
}
