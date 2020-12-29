data "template_file" "BasionHost_data" {
       template             = file("${path.module}/templateFiles/BasionHost.tpl")
}

resource "aws_instance" "BasionHost" {
  depends_on                  = [aws_vpc_dhcp_options_association.dns_resolver,aws_directory_service_directory.MyActiveDirectory,aws_vpc_dhcp_options.DhcpOptionforAD,aws_iam_instance_profile.BackupInst_profile]
  ami                         = var.CENTOS7_CUSTOMIZED_AMI
  instance_type               = var.NAT_INST_TYPE
  iam_instance_profile        = aws_iam_instance_profile.BackupInst_profile.name
  associate_public_ip_address = true
  source_dest_check           = false
  disable_api_termination     = false
  subnet_id                   = aws_subnet.PublicSubnetB.id
  availability_zone           = join("", [ var.AWS_REGION, "b"])
  vpc_security_group_ids      = [aws_default_security_group.default.id]
  key_name                    = var.NAT_INST_KEY_NAME
  ebs_optimized               = false
  monitoring                  = false
  private_ip                  = var.BASIONHOST_PRIVATE_IP
  user_data                   = data.template_file.BasionHost_data.rendered
provisioner "local-exec" {command = "echo [BasionHost:vars] > ${path.module}/dynamicFiles/aws_hosts"}
provisioner "local-exec" {command = "echo ansible_ssh_private_key_file=${path.module}/keyDir/Vpn.public.pem >> ${path.module}/dynamicFiles/aws_hosts"}
provisioner "local-exec" {command = "echo [BasionHost] >> ${path.module}/dynamicFiles/aws_hosts"}
provisioner "local-exec" {command = "echo ${aws_instance.BasionHost.public_ip} >> ${path.module}/dynamicFiles/aws_hosts"}
provisioner "local-exec" {command = "/bin/bash ${path.module}/unixScripts/loopTillport22ComeUp ${aws_instance.BasionHost.public_ip}"} 
provisioner "local-exec" {command = "ansible-playbook -e bind_password=${var.DOMAINADMINPASSWORD} -i ${path.module}/dynamicFiles/aws_hosts ${path.module}/playBooks/BasionHost.yml"}

  
  tags = {
            Name               = "BasionHost"
            OStype             = "Centos7"
            EnviromentType     = var.MYENVTYPE
            Role               = "BasionHost" 
            Role               = "BackupHost" 
            Role               = "VpnServer" 
            Role               = "NatServer"
            ResourceType       = "EC2Instance"
            Department         = "Marketing"
            Location           = var.LOCATION

 }


}
