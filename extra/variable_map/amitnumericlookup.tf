variable "choosesubnet" {
  type = map

  default = {
    1 = "subnetA"
    2 = "subnetB"
    3 = "subnetC"
  }

}

output "choosesubnet_name" {
  value = lookup(var.choosesubnet, 3)
}
