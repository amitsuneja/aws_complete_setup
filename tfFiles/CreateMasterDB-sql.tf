resource "aws_ebs_volume" "MasterDB-Datavol0001" {
  availability_zone = join("", [ var.AWS_REGION, "a"])
  size              = 1
  type              = "gp2"
  encrypted         = false
  tags = { 
	Name = "MasterDB-Datavol0001"
        MountPoint = "/datavol0001"
        Enviroment="Production"
        Role="MasterDB" 
     }
}

resource "aws_ebs_volume" "MasterDB-Datavol0002" {
  availability_zone = join("", [ var.AWS_REGION, "a"])
  size              = 1
  type              = "gp2"
  encrypted         = false
  tags = {
        Name = "MasterDB-Datavol0002"
        MountPoint = "/datavol0002"
        Enviroment="Production"
        Role="MasterDB"
 }
}


data "template_file" "MasterDB-sql_data" {
	template = file("${path.module}/templateFiles/MasterDB-sql.tpl")
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

resource "aws_instance" "MasterDB-sql" {
       depends_on = [aws_route_table_association.PvtSub-RT-Association_A,aws_route_table_association.PvtSub-RT-Association_B,aws_ebs_volume.MasterDB-Datavol0001,aws_ebs_volume.MasterDB-Datavol0002,aws_instance.BasionHost]
       ami  = var.CENTOS7_CUSTOMIZED_AMI
       instance_type = var.NAT_INST_TYPE
       associate_public_ip_address = false
       disable_api_termination = false
       subnet_id = aws_subnet.PvtSubnetA.id
       availability_zone = join("", [ var.AWS_REGION, "a"])
       vpc_security_group_ids = [aws_security_group.BE_SG.id]
       key_name = var.NAT_INST_KEY_NAME
       source_dest_check = true
       ebs_optimized = false
       monitoring = false
       private_ip = var.MasterDB_INST_PRIVATE_IP
       user_data = data.template_file.MasterDB-sql_data.rendered
  tags = {
            Name               = "MasterDB-sql"
            OStype             = "Centos7"
            EnviromentType     = var.MYENVTYPE
            Role               = "MasterDB"
            ResourceType       = "EC2Instance"
            Department         = "Marketing"
            Location           = var.LOCATION

     }
}


resource "aws_volume_attachment" "Attach-MasterDB-Datavol0001" {
  device_name = "/dev/sdh"
  volume_id   = aws_ebs_volume.MasterDB-Datavol0001.id
  instance_id = aws_instance.MasterDB-sql.id
}

resource "aws_volume_attachment" "Attach-MasterDB-Datavol0002" {
  device_name = "/dev/sdi"
  volume_id   = aws_ebs_volume.MasterDB-Datavol0002.id
  instance_id = aws_instance.MasterDB-sql.id
}
