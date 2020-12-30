variable "image_bucket_names" {
  type = map

  default = {
    development = "bucket-dev"
    staging = "bucket-for-staging"
    preprod = "bucket-name-for-preprod"
    production = "bucket-for-production"
  }

}

output "image_bucket_name" {
  value = lookup(var.image_bucket_names, "staging")
}
