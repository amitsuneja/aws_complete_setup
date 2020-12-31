To Download this Repo : 
https://github.com/amitsuneja/aws_complete_setup.git


----------------------------------------------------------------------------------------------------------

We are trying to implement pipeline using AWS teraafrom

l. Generate ssh key from aws portal by name Vpn.public in portal and save its private key  with name Vpn.public.ppk in your unix host from where you are running terraform scripts in a directory tfFiles/keyDir/Vpn.public.ppk

Note: do not change file names like Vpn.public in aws and Vpn.public.ppk for private key when saving private key from aws.


2. Copy Vpn.public.ppk in tfFiles/keyDir/Vpn.public.ppk


3. run script tfFiles/unixScripts/convertPpkToPem

 Note this script assume you are using RHEL7 server as terraform server from where you will run terraform apply.
 elseyou can download pem file from AWS or use windows to convert ppk to pem
 .ppk is for putty and .pem is to login from unix to unix

Note : once Bastion host is created with rendered user data using template  . We will create a dynamic inverntory and store its IP in tfFiles/dynamicFiles/aws_hosts, then we will pick terraform variable and pass it to playbook we will run on bastion host. Remember -e switch in ansible is use to pass variable from  CLI , -i in to specify inventory 
          
example : ansible-playbook -e "user_name=bob user_create=yes" user.yml 
we passed 2 variables to ansible in above example.


4. edit /etc/ansible/ansible.cfg and add deprecation_warnings=False

5. Check the .bashrc file given in repo and set your .bashrc accordingly.


6. cd tfFiles and run terraform plan and terraform apply.


7. Must Pay attention to Bastion.tf - It shows how to connect ansible to terraform using local-exec provisioner, it invokes a local executable after a resource is created. This invokes a process on the machine running Terraform, not on the resource. 

${path.module} is variable of terraform.
provisioner "local-exec" {command = "echo [BasionHost:vars] > ${path.module}/dynamicFiles/aws_hosts"}

Ansible need to know which key to use when it will run playbook for bastin host 
provisioner "local-exec" {command = "echo ansible_ssh_private_key_file=${path.module}/keyDir/Vpn.public.pem >> ${path.module}/dynamicFiles/aws_hosts"}

Creating local file Inventory for Ansible.
provisioner "local-exec" {command = "echo [BasionHost] >> ${path.module}/dynamicFiles/aws_hosts"}

Need to know then private IP of Bastin host and dump it in Ansible Inventory.
provisioner "local-exec" {command = "echo ${aws_instance.BasionHost.public_ip} >> ${path.module}/dynamicFiles/aws_hosts"}

Loop till port 22 starting listening ..
provisioner "local-exec" {command = "/bin/bash ${path.module}/unixScripts/loopTillport22ComeUp ${aws_instance.BasionHost.public_ip}"}


Lets run playbook on Bastin Host.
provisioner "local-exec" {command = "ansible-playbook -e bind_password=${var.DOMAINADMINPASSWORD} -i ${path.module}/dynamicFiles/aws_hosts ${path.module}/playBooks/BasionHost.yml"}




 And also show how how we read  .tpl(template file as data and passwd it as user data to new server(tpl file contain  script/commands we cant to execute on host once it got created, it happens before local-exec steps.)







8. Must Pay attention to  how we picked variable from teraaform and passed then to data -this data will be used to generate userdata for server creation.
 
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



9. Must pay attenion to LaunchConfiguration.tf where we did not used template gile , instead we generated user_data on the fly.

    user_data                   = <<EOF
                                  #!/bin/bash
                                  yum install -y httpd
                                  systemctl enable httpd
                                  systemctl start httpd
                                  echo "I am Web Server" > /var/www/html/index.html
                                  EOF



10. Must pay attension to CreateAdwriter.tf. Check how we wrote templateFiles/Adwriter.tpl

This is like a .bat file of windows . <script> and </script> is must , Cant pass more number of command here ,SO we try to use & to join commands. Quite tricky . Make sure to redirect output so that you can read logs later.



winrm - is used by windows , you can connect via http or https to run windows command . We used http .
It is littel complex and if you face issue with it then you can use /extra/connect_to_windows_using_python3_pywinrm/windows_connect.py this python3 script , Manually change IP and password and run it . If it runs then your winrm iis working .
I used python here for troubleshooting as it has better error in output then terraform.
 
<script>
winrm quickconfig -q & winrm set winrm/config/winrm @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"} & winrm set winrm/config/service @{AllowUnencrypted="true"} > c:\userDatatStatus.txt
</script>


Powershell commnds goes here


<powershell>
echo "Status before userdata powershell executed" | Out-File C:\userDatabeforepowershellstatus.txt
-changes in firewall.
netsh advfirewall firewall add rule name="WinRM in http" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
netsh advfirewall firewall add rule name="WinRM in https" protocol=TCP dir=in profile=any localport=5986 remoteip=any localip=any action=allow
netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow
-reset password for local admin user , so later we can login with it and connect to AD.
$admin = [ADSI]("WinNT://./administrator, user")
$admin.SetPassword("${ADMIN_PASSWORD_WINSERVER}")
echo "Status after userdata powershell executed" | Out-File C:\userDataafterpowershellstatus.txt
</powershell>
   

---------------------------------------------------------------------------------------------------------------------


















--------------------------------------------------------------------------------------------------------------
few good links
--------------------------------------------------------------------------------------------------------------



https://github.com/C2Devel/terraform-examples/tree/master/cases


https://www.techtransit.org/set-up-aws-ec2-cli-tools-on-centos-rhel-linux-or-mac-os-x/


https://techoral.com/blog/java/install-openjdk-8-linux.html


https://alexharv074.github.io/2019/11/23/adventures-in-the-terraform-dsl-part-x-templates.html#introduction


https://thirdiron.com/one-step-beyond-intro-tutorials-configure-terraform-server-https-ssl/


# Jinja templating
https://ttl255.com/jinja2-tutorial-part-1-introduction-and-variable-substitution/
-----------------------------------------------------------------------------------------------------------------
