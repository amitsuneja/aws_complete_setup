resource "aws_iam_role" "mysqlbackup-role" {  
  name = "mysqlbackup-role"
  description = "Role to take Backup of MySQL Database"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}




resource "aws_iam_policy" "mysqlbackup-policy" {  
  name        = "mysqlbackup-policy"
  path        = "/service-role/"
  description = "Policy used to attach to mysqlbackup-role"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:HeadBucket",
                "s3:ListObjects"
            ],
            "Resource": "*"
        },
        {
            "Sid": "VisualEditor1",
            "Effect": "Allow",
            "Action": "s3:*",
	    "Resource": "arn:aws:s3:::amitsuneja.xyz-mysql-backup"
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "mysqlbackup_attachment" {  
  name       = "mysqlbackup_attachment"
  policy_arn = aws_iam_policy.mysqlbackup-policy.arn
  roles      = [aws_iam_role.mysqlbackup-role.id]
}

resource "aws_iam_instance_profile" "BackupInst_profile" {
      name  = "BackupInst_profile"
      role  = aws_iam_role.mysqlbackup-role.name

}
