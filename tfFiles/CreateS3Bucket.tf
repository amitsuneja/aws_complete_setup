resource "aws_s3_bucket" "MyS3Bucket" {
  bucket = var.S3_BUCKET_NAME
  acl    = "private"
  versioning { enabled = true }
/* 
  region = var.AWS_REGION
*/
  tags =  {
    Name         = var.S3_BUCKET_NAME
    Environment  = var.MYENVTYPE
    Role         = "DailyBackupOfMySqlDatabases"
    ResourceType = "S3Bucket"
  }
}
