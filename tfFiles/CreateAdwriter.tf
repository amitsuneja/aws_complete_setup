#### INLINE - Bootsrap Windows Server 2012 R2 ###
data "template_file" "init" {
       template = file("${path.module}/templateFiles/Adwriter.tpl")
       vars = { 
                 ADMIN_PASSWORD_WINSERVER = var.ADMIN_PASSWORD_WINSERVER
       }
}

resource "aws_instance" "AdWriter" {
       depends_on = [aws_instance.BasionHost]
       ami                         = var.WINDOWS2012BASER2AMI
       instance_type               = var.NAT_INST_TYPE
       key_name                    = var.NAT_INST_KEY_NAME
       user_data                   = data.template_file.init.rendered
       subnet_id                   = aws_subnet.PublicSubnetA.id
       private_ip                  = var.ADWRITER_INST_PRIVATE_IP
       associate_public_ip_address = true
       disable_api_termination     = false
       availability_zone           = join("", [ var.AWS_REGION, "a"])
       vpc_security_group_ids      = [aws_default_security_group.default.id]
       source_dest_check           = true
       ebs_optimized               = false
       monitoring                  = false
       
       #Allow AWS infrastructure metadata to propagate 
         provisioner "local-exec" {
                   command = "sleep 120"
        }
       #Copy Power shell Script on AdWriter
         provisioner "file" {
                   source      = "${path.module}/winScripts/"
                   destination = "C:\\scripts"
                   connection  {
                                    type        = "winrm"
                                    user        = "Administrator"
                                    password    = var.ADMIN_PASSWORD_WINSERVER
                                    host        = aws_instance.AdWriter.public_ip
				    port	= 5985
                                 }
                    }
      
        #Set Execution Policy to Remote-Signed, Configure Active Directory
          provisioner "remote-exec" {
                    connection  {
                                     type        = "winrm"
                                     user        = "Administrator"
                                     password    = var.ADMIN_PASSWORD_WINSERVER
                                     agent       = "false"
				     host        = aws_instance.AdWriter.public_ip
                                  }
                                     inline = [
                                               "powershell.exe Set-ExecutionPolicy RemoteSigned -force",
                                               "powershell.exe -version 4 -ExecutionPolicy Bypass -File C:\\scripts\\JoinActDir.ps1"
                                              ]
                     }

  tags = {
            Name               = "AdWriter"
            OStype             = "Window2012R2"
            EnviromentType     = var.MYENVTYPE
            Role               = "ActiveDirectoryWriter"
            ResourceType       = "EC2Instance"
            Department         = "Marketing"
            Location           = var.LOCATION

 }
}
