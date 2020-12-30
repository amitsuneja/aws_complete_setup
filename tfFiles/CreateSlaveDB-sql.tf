resource "aws_ebs_volume" "SlaveDB-Datavol0001" {
  availability_zone =  join("", [ var.AWS_REGION, "b"])
  size              = 1
  type              = "gp2"
  encrypted         = false
  tags = {
        Name = "SlaveDB-Datavol0001"
        MountPoint = "/datavol0001"
 }
}

resource "aws_ebs_volume" "SlaveDB-Datavol0002" {
  availability_zone = join("", [ var.AWS_REGION, "b"])
  size              = 1
  type              = "gp2"
  encrypted         = false
  tags = {
        Name = "SlaveDB-Datavol0002"
        MountPoint = "/datavol0002"
 }
}


data "template_file" "SlaveDB-sql_data" {
       template = file("${path.module}/templateFiles/SlaveDB-sql.tpl")
       vars = {
               DOMAINNAME          = var.DOMAINNAME
               DOMAINADMINPASSWORD = var.DOMAINADMINPASSWORD
               MYREPUSER           = var.MYREPUSER
               MYREPPASS           = var.MYREPPASS
               NEWROOT             = var.NEWROOT
               NEWROOTPASS         = var.NEWROOTPASS
               MasterDB_INST_PRIVATE_IP = var.MasterDB_INST_PRIVATE_IP
       }
}

resource "aws_instance" "SlaveDB-sql" {
       depends_on = [aws_route_table_association.PvtSub-RT-Association_A,aws_route_table_association.PvtSub-RT-Association_B,aws_ebs_volume.SlaveDB-Datavol0001,aws_ebs_volume.SlaveDB-Datavol0002,aws_volume_attachment.Attach-MasterDB-Datavol0001,aws_volume_attachment.Attach-MasterDB-Datavol0002]
       ami  = var.CENTOS7_CUSTOMIZED_AMI
       instance_type = var.NAT_INST_TYPE
       associate_public_ip_address = false
       disable_api_termination = false
       subnet_id = aws_subnet.PvtSubnetB.id
       availability_zone = join("", [ var.AWS_REGION, "b"])
       vpc_security_group_ids = [aws_security_group.BE_SG.id]
       key_name = var.NAT_INST_KEY_NAME
       source_dest_check = true
       ebs_optimized = false
       monitoring = false
       private_ip = var.SlaveDB_INST_PRIVATE_IP
       user_data = data.template_file.SlaveDB-sql_data.rendered
  tags = {
            Name               = "SlaveDB-sql"
            OStype             = "Centos7"
            EnviromentType     = var.MYENVTYPE
            Role               = "SlaveDB"
            ResourceType       = "EC2Instance"
            Department         = "Marketing"
            Location           = var.LOCATION

      }

}


resource "aws_volume_attachment" "Attach-SlaveDB-Datavol0001" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.SlaveDB-Datavol0001.id
  instance_id = aws_instance.SlaveDB-sql.id

}

resource "aws_volume_attachment" "Attach-SlaveDB-Datavol0002" {
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.SlaveDB-Datavol0002.id
  instance_id = aws_instance.SlaveDB-sql.id
}

