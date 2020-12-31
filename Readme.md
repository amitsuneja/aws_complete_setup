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



once server is up , we slept terraform for 120 seconds and backend powershelll script is renaming host and changing password.
After that we used provisioner "file" {} to copy Join Active directory.PS to this server.
And then remote-exec {} to execute script and join to domain.


----------------------------------------------------------------------------------------------------------------------
Confirguration:
Main.tf
Network.tf
Subnet.tf
Igw.tf
RouteTablesforPublicSubnets.tf
SecurityGroups.tf
CreateS3Bucket.tf
CreateIAMRoleAndPolicy.tf
ActiveDirectory.tf
CreateRoute53PrivateHostedZone.tf
CreateBasionHost.tf
RoutingForPvtSubnets.tf
CreateMasterDB-sql.tf
CreateSlaveDB-sql.tf
ApplicationLB.tf (aws_alb,aws_alb_target_group,aws_alb_target_group_attachment,aws_alb_listener,aws_alb_listener_rule)
LaunchConfiguration.tf
AutoScalingGroup.tf




-------------------------------------------------------------------------------------------------------------------
Route53:

Example Records for DNS:
____________________________
2 Hosted PVT ZOneSets	

- amitsuneja.xyz	Forward Lookup

- 0.10.in-addr.arpa	Reverse Lookup




SRV Records amitsuneja.xyz:	
____________________________________

- _ldap._tcp.amitsuneja.xyz	service = 0 100 389 aws-8abe4c4d28.amitsuneja.xyz

- _ldap._tcp.dc._msdcs.amitsuneja.xyz	service = 0 100 389 aws-8abe4c4d28.amitsuneja.xyz

- _ldap._tcp.pdc._msdcs.amitsuneja.xyz	service = 0 100 389 aws-8abe4c4d28.amitsuneja.xyz

- _ldap._tcp.gc._msdcs.amitsuneja.xyz	service = 0 100 3268 aws-8abe4c4d28.amitsuneja.xyz

- _gc._tcp.amitsuneja.xyz	service = 0 100 3268 aws-8abe4c4d28.amitsuneja.xyz

- _kerberos._tcp.amitsuneja.xyz	service = 0 100 88 aws-8abe4c4d28.amitsuneja.xyz

- _kerberos._udp.amitsuneja.xyz	service = 0 100 88 aws-8abe4c4d28.amitsuneja.xyz

- _kpasswd._tcp.amitsuneja.xyz	service = 0 100 464 aws-8abe4c4d28.amitsuneja.xyz

- _kpasswd._udp.amitsuneja.xyz	service = 0 100 464 aws-8abe4c4d28.amitsuneja.xyz




A typerecord in  amitsuneja.xyz:
_________________________________
- amitsuneja.xyz	10.0.5.236

- AWS-9616457825	10.0.5.236




PTR Record in 0.10.in-addr.arpa:	
_______________________________

- 236.5 (which will become 236.5.0.10.in-addr.arpa)	AWS-9616457825.amitsuneja.xyz
--------------------------------------------------------------------------------------------------------------------
Network:
Subnetting: 
----------
- Mumbai		VPC_CIDR_BLOCK          	10.0.0.0/21							
- Subnet1		10.0.0.0	24	254	10.0.0.1	10.0.0.254	10.0.0.255	PublicSubnetA	used
- Subnet2		10.0.1.0	24	254	10.0.1.1	10.0.1.254	10.0.1.255	PublicSubnetB	used
- Subnet3		10.0.2.0	24	254	10.0.2.1	10.0.2.254	10.0.2.255	PublicSubnetC	free
- Subnet4		10.0.3.0	24	254	10.0.3.1	10.0.3.254	10.0.3.255	PublicSubnetD	free
- Subnet5		10.0.4.0	24	254	10.0.4.1	10.0.4.254	10.0.4.255	PrivateSubnetA	used
- Subnet6		10.0.5.0	24	254	10.0.5.1	10.0.5.254	10.0.5.255	PrivateSubnetB	used
- Subnet7		10.0.6.0	24	254	10.0.6.1	10.0.6.254	10.0.6.255	PrivateSubnetC	free
- Subnet8		10.0.7.0	24	254	10.0.7.1	10.0.7.254	10.0.7.255	PrivateSubnetD	free

- N.Virginia		VPC_CIDR_BLOCK			10.0.8.0/21							
- Subnet9		10.0.8.0	24	254	10.0.8.1	10.0.8.254	10.0.8.255	PublicSubnetA	
- Subnet10		10.0.9.0	24	254	10.0.9.1	10.0.9.254	10.0.9.255	PublicSubnetB	
- Subnet11		10.0.10.0	24	254	10.0.10.1	10.0.10.254	10.0.10.255	PublicSubnetC	
- Subnet12		10.0.11.0	24	254	10.0.11.1	10.0.11.254	10.0.11.255	PublicSubnetD	
- Subnet13		10.0.12.0	24	254	10.0.12.1	10.0.12.254	10.0.12.255	PrivateSubnetA	
- Subnet14		10.0.13.0	24	254	10.0.13.1	10.0.13.254	10.0.13.255	PrivateSubnetB	
- Subnet15		10.0.14.0	24	254	10.0.14.1	10.0.14.254	10.0.14.255	PrivateSubnetC	
- Subnet16		10.0.15.0	24	254	10.0.15.1	10.0.15.254	10.0.15.255	PrivateSubnetD	

For FutureUse:
-------------
- Subnet17	10.0.16.0	24	254	10.0.16.1	10.0.16.254	10.0.16.255
- Subnet18	10.0.17.0	24	254	10.0.17.1	10.0.17.254	10.0.17.255
- Subnet19	10.0.18.0	24	254	10.0.18.1	10.0.18.254	10.0.18.255
- Subnet20	10.0.19.0	24	254	10.0.19.1	10.0.19.254	10.0.19.255
- Subnet21	10.0.20.0	24	254	10.0.20.1	10.0.20.254	10.0.20.255
- Subnet22	10.0.21.0	24	254	10.0.21.1	10.0.21.254	10.0.21.255
- Subnet23	10.0.22.0	24	254	10.0.22.1	10.0.22.254	10.0.22.255
- Subnet24	10.0.23.0	24	254	10.0.23.1	10.0.23.254	10.0.23.255
- Subnet25	10.0.24.0	24	254	10.0.24.1	10.0.24.254	10.0.24.255
- Subnet26	10.0.25.0	24	254	10.0.25.1	10.0.25.254	10.0.25.255
- Subnet27	10.0.26.0	24	254	10.0.26.1	10.0.26.254	10.0.26.255
- Subnet28	10.0.27.0	24	254	10.0.27.1	10.0.27.254	10.0.27.255
- Subnet29	10.0.28.0	24	254	10.0.28.1	10.0.28.254	10.0.28.255
- Subnet30	10.0.29.0	24	254	10.0.29.1	10.0.29.254	10.0.29.255
- Subnet31	10.0.30.0	24	254	10.0.30.1	10.0.30.254	10.0.30.255
- Subnet32	10.0.31.0	24	254	10.0.31.1	10.0.31.254	10.0.31.255
- Subnet33	10.0.32.0	24	254	10.0.32.1	10.0.32.254	10.0.32.255
- Subnet34	10.0.33.0	24	254	10.0.33.1	10.0.33.254	10.0.33.255
- Subnet35	10.0.34.0	24	254	10.0.34.1	10.0.34.254	10.0.34.255
- Subnet36	10.0.35.0	24	254	10.0.35.1	10.0.35.254	10.0.35.255
- Subnet37	10.0.36.0	24	254	10.0.36.1	10.0.36.254	10.0.36.255
- Subnet38	10.0.37.0	24	254	10.0.37.1	10.0.37.254	10.0.37.255
- Subnet39	10.0.38.0	24	254	10.0.38.1	10.0.38.254	10.0.38.255
- Subnet40	10.0.39.0	24	254	10.0.39.1	10.0.39.254	10.0.39.255
- Subnet41	10.0.40.0	24	254	10.0.40.1	10.0.40.254	10.0.40.255
- Subnet42	10.0.41.0	24	254	10.0.41.1	10.0.41.254	10.0.41.255
- Subnet43	10.0.42.0	24	254	10.0.42.1	10.0.42.254	10.0.42.255
- Subnet44	10.0.43.0	24	254	10.0.43.1	10.0.43.254	10.0.43.255
- Subnet45	10.0.44.0	24	254	10.0.44.1	10.0.44.254	10.0.44.255
- Subnet46	10.0.45.0	24	254	10.0.45.1	10.0.45.254	10.0.45.255
- Subnet47	10.0.46.0	24	254	10.0.46.1	10.0.46.254	10.0.46.255
- Subnet48	10.0.47.0	24	254	10.0.47.1	10.0.47.254	10.0.47.255
- Subnet49	10.0.48.0	24	254	10.0.48.1	10.0.48.254	10.0.48.255
- Subnet50	10.0.49.0	24	254	10.0.49.1	10.0.49.254	10.0.49.255
- Subnet51	10.0.50.0	24	254	10.0.50.1	10.0.50.254	10.0.50.255
- Subnet52	10.0.51.0	24	254	10.0.51.1	10.0.51.254	10.0.51.255
- Subnet53	10.0.52.0	24	254	10.0.52.1	10.0.52.254	10.0.52.255
- Subnet54	10.0.53.0	24	254	10.0.53.1	10.0.53.254	10.0.53.255
- Subnet55	10.0.54.0	24	254	10.0.54.1	10.0.54.254	10.0.54.255
- Subnet56	10.0.55.0	24	254	10.0.55.1	10.0.55.254	10.0.55.255
- Subnet57	10.0.56.0	24	254	10.0.56.1	10.0.56.254	10.0.56.255
- Subnet58	10.0.57.0	24	254	10.0.57.1	10.0.57.254	10.0.57.255
- Subnet59	10.0.58.0	24	254	10.0.58.1	10.0.58.254	10.0.58.255
- Subnet60	10.0.59.0	24	254	10.0.59.1	10.0.59.254	10.0.59.255
- Subnet61	10.0.60.0	24	254	10.0.60.1	10.0.60.254	10.0.60.255
- Subnet62	10.0.61.0	24	254	10.0.61.1	10.0.61.254	10.0.61.255
- Subnet63	10.0.62.0	24	254	10.0.62.1	10.0.62.254	10.0.62.255
- Subnet64	10.0.63.0	24	254	10.0.63.1	10.0.63.254	10.0.63.255
- Subnet65	10.0.64.0	24	254	10.0.64.1	10.0.64.254	10.0.64.255
- Subnet66	10.0.65.0	24	254	10.0.65.1	10.0.65.254	10.0.65.255
- Subnet67	10.0.66.0	24	254	10.0.66.1	10.0.66.254	10.0.66.255
- Subnet68	10.0.67.0	24	254	10.0.67.1	10.0.67.254	10.0.67.255
- Subnet69	10.0.68.0	24	254	10.0.68.1	10.0.68.254	10.0.68.255
- Subnet70	10.0.69.0	24	254	10.0.69.1	10.0.69.254	10.0.69.255
- Subnet71	10.0.70.0	24	254	10.0.70.1	10.0.70.254	10.0.70.255
- Subnet72	10.0.71.0	24	254	10.0.71.1	10.0.71.254	10.0.71.255
- Subnet73	10.0.72.0	24	254	10.0.72.1	10.0.72.254	10.0.72.255
- Subnet74	10.0.73.0	24	254	10.0.73.1	10.0.73.254	10.0.73.255
- Subnet75	10.0.74.0	24	254	10.0.74.1	10.0.74.254	10.0.74.255
- Subnet76	10.0.75.0	24	254	10.0.75.1	10.0.75.254	10.0.75.255
- Subnet77	10.0.76.0	24	254	10.0.76.1	10.0.76.254	10.0.76.255
- Subnet78	10.0.77.0	24	254	10.0.77.1	10.0.77.254	10.0.77.255
- Subnet79	10.0.78.0	24	254	10.0.78.1	10.0.78.254	10.0.78.255
- Subnet80	10.0.79.0	24	254	10.0.79.1	10.0.79.254	10.0.79.255
- Subnet81	10.0.80.0	24	254	10.0.80.1	10.0.80.254	10.0.80.255
- Subnet82	10.0.81.0	24	254	10.0.81.1	10.0.81.254	10.0.81.255
- Subnet83	10.0.82.0	24	254	10.0.82.1	10.0.82.254	10.0.82.255
- Subnet84	10.0.83.0	24	254	10.0.83.1	10.0.83.254	10.0.83.255
- Subnet85	10.0.84.0	24	254	10.0.84.1	10.0.84.254	10.0.84.255
- Subnet86	10.0.85.0	24	254	10.0.85.1	10.0.85.254	10.0.85.255
- Subnet87	10.0.86.0	24	254	10.0.86.1	10.0.86.254	10.0.86.255
- Subnet88	10.0.87.0	24	254	10.0.87.1	10.0.87.254	10.0.87.255
- Subnet89	10.0.88.0	24	254	10.0.88.1	10.0.88.254	10.0.88.255
- Subnet90	10.0.89.0	24	254	10.0.89.1	10.0.89.254	10.0.89.255
- Subnet91	10.0.90.0	24	254	10.0.90.1	10.0.90.254	10.0.90.255
- Subnet92	10.0.91.0	24	254	10.0.91.1	10.0.91.254	10.0.91.255
- Subnet93	10.0.92.0	24	254	10.0.92.1	10.0.92.254	10.0.92.255
- Subnet94	10.0.93.0	24	254	10.0.93.1	10.0.93.254	10.0.93.255
- Subnet95	10.0.94.0	24	254	10.0.94.1	10.0.94.254	10.0.94.255
- Subnet96	10.0.95.0	24	254	10.0.95.1	10.0.95.254	10.0.95.255
- Subnet97	10.0.96.0	24	254	10.0.96.1	10.0.96.254	10.0.96.255
- Subnet98	10.0.97.0	24	254	10.0.97.1	10.0.97.254	10.0.97.255
- Subnet99	10.0.98.0	24	254	10.0.98.1	10.0.98.254	10.0.98.255
- Subnet100	10.0.99.0	24	254	10.0.99.1	10.0.99.254	10.0.99.255
- Subnet101	10.0.100.0	24	254	10.0.100.1	10.0.100.254	10.0.100.255
- Subnet102	10.0.101.0	24	254	10.0.101.1	10.0.101.254	10.0.101.255
- Subnet103	10.0.102.0	24	254	10.0.102.1	10.0.102.254	10.0.102.255
- Subnet104	10.0.103.0	24	254	10.0.103.1	10.0.103.254	10.0.103.255
- Subnet105	10.0.104.0	24	254	10.0.104.1	10.0.104.254	10.0.104.255
- Subnet106	10.0.105.0	24	254	10.0.105.1	10.0.105.254	10.0.105.255
- Subnet107	10.0.106.0	24	254	10.0.106.1	10.0.106.254	10.0.106.255
- Subnet108	10.0.107.0	24	254	10.0.107.1	10.0.107.254	10.0.107.255
- Subnet109	10.0.108.0	24	254	10.0.108.1	10.0.108.254	10.0.108.255
- Subnet110	10.0.109.0	24	254	10.0.109.1	10.0.109.254	10.0.109.255
- Subnet111	10.0.110.0	24	254	10.0.110.1	10.0.110.254	10.0.110.255
- Subnet112	10.0.111.0	24	254	10.0.111.1	10.0.111.254	10.0.111.255
- Subnet113	10.0.112.0	24	254	10.0.112.1	10.0.112.254	10.0.112.255
- Subnet114	10.0.113.0	24	254	10.0.113.1	10.0.113.254	10.0.113.255
- Subnet115	10.0.114.0	24	254	10.0.114.1	10.0.114.254	10.0.114.255
- Subnet116	10.0.115.0	24	254	10.0.115.1	10.0.115.254	10.0.115.255
- Subnet117	10.0.116.0	24	254	10.0.116.1	10.0.116.254	10.0.116.255
- Subnet118	10.0.117.0	24	254	10.0.117.1	10.0.117.254	10.0.117.255
- Subnet119	10.0.118.0	24	254	10.0.118.1	10.0.118.254	10.0.118.255
- Subnet120	10.0.119.0	24	254	10.0.119.1	10.0.119.254	10.0.119.255
- Subnet121	10.0.120.0	24	254	10.0.120.1	10.0.120.254	10.0.120.255
- Subnet122	10.0.121.0	24	254	10.0.121.1	10.0.121.254	10.0.121.255
- Subnet123	10.0.122.0	24	254	10.0.122.1	10.0.122.254	10.0.122.255
- Subnet124	10.0.123.0	24	254	10.0.123.1	10.0.123.254	10.0.123.255
- Subnet125	10.0.124.0	24	254	10.0.124.1	10.0.124.254	10.0.124.255
- Subnet126	10.0.125.0	24	254	10.0.125.1	10.0.125.254	10.0.125.255
- Subnet127	10.0.126.0	24	254	10.0.126.1	10.0.126.254	10.0.126.255
- Subnet128	10.0.127.0	24	254	10.0.127.1	10.0.127.254	10.0.127.255
- Subnet129	10.0.128.0	24	254	10.0.128.1	10.0.128.254	10.0.128.255
- Subnet130	10.0.129.0	24	254	10.0.129.1	10.0.129.254	10.0.129.255
- Subnet131	10.0.130.0	24	254	10.0.130.1	10.0.130.254	10.0.130.255
- Subnet132	10.0.131.0	24	254	10.0.131.1	10.0.131.254	10.0.131.255
- Subnet133	10.0.132.0	24	254	10.0.132.1	10.0.132.254	10.0.132.255
- Subnet134	10.0.133.0	24	254	10.0.133.1	10.0.133.254	10.0.133.255
- Subnet135	10.0.134.0	24	254	10.0.134.1	10.0.134.254	10.0.134.255
- Subnet136	10.0.135.0	24	254	10.0.135.1	10.0.135.254	10.0.135.255
- Subnet137	10.0.136.0	24	254	10.0.136.1	10.0.136.254	10.0.136.255
- Subnet138	10.0.137.0	24	254	10.0.137.1	10.0.137.254	10.0.137.255
- Subnet139	10.0.138.0	24	254	10.0.138.1	10.0.138.254	10.0.138.255
- Subnet140	10.0.139.0	24	254	10.0.139.1	10.0.139.254	10.0.139.255
- Subnet141	10.0.140.0	24	254	10.0.140.1	10.0.140.254	10.0.140.255
- Subnet142	10.0.141.0	24	254	10.0.141.1	10.0.141.254	10.0.141.255
- Subnet143	10.0.142.0	24	254	10.0.142.1	10.0.142.254	10.0.142.255
- Subnet144	10.0.143.0	24	254	10.0.143.1	10.0.143.254	10.0.143.255
- Subnet145	10.0.144.0	24	254	10.0.144.1	10.0.144.254	10.0.144.255
- Subnet146	10.0.145.0	24	254	10.0.145.1	10.0.145.254	10.0.145.255
- Subnet147	10.0.146.0	24	254	10.0.146.1	10.0.146.254	10.0.146.255
- Subnet148	10.0.147.0	24	254	10.0.147.1	10.0.147.254	10.0.147.255
- Subnet149	10.0.148.0	24	254	10.0.148.1	10.0.148.254	10.0.148.255
- Subnet150	10.0.149.0	24	254	10.0.149.1	10.0.149.254	10.0.149.255
- Subnet151	10.0.150.0	24	254	10.0.150.1	10.0.150.254	10.0.150.255
- Subnet152	10.0.151.0	24	254	10.0.151.1	10.0.151.254	10.0.151.255
- Subnet153	10.0.152.0	24	254	10.0.152.1	10.0.152.254	10.0.152.255
- Subnet154	10.0.153.0	24	254	10.0.153.1	10.0.153.254	10.0.153.255
- Subnet155	10.0.154.0	24	254	10.0.154.1	10.0.154.254	10.0.154.255
- Subnet156	10.0.155.0	24	254	10.0.155.1	10.0.155.254	10.0.155.255
- Subnet157	10.0.156.0	24	254	10.0.156.1	10.0.156.254	10.0.156.255
- Subnet158	10.0.157.0	24	254	10.0.157.1	10.0.157.254	10.0.157.255
- Subnet159	10.0.158.0	24	254	10.0.158.1	10.0.158.254	10.0.158.255
- Subnet160	10.0.159.0	24	254	10.0.159.1	10.0.159.254	10.0.159.255
- Subnet161	10.0.160.0	24	254	10.0.160.1	10.0.160.254	10.0.160.255
- Subnet162	10.0.161.0	24	254	10.0.161.1	10.0.161.254	10.0.161.255
- Subnet163	10.0.162.0	24	254	10.0.162.1	10.0.162.254	10.0.162.255
- Subnet164	10.0.163.0	24	254	10.0.163.1	10.0.163.254	10.0.163.255
- Subnet165	10.0.164.0	24	254	10.0.164.1	10.0.164.254	10.0.164.255
- Subnet166	10.0.165.0	24	254	10.0.165.1	10.0.165.254	10.0.165.255
- Subnet167	10.0.166.0	24	254	10.0.166.1	10.0.166.254	10.0.166.255
- Subnet168	10.0.167.0	24	254	10.0.167.1	10.0.167.254	10.0.167.255
- Subnet169	10.0.168.0	24	254	10.0.168.1	10.0.168.254	10.0.168.255
- Subnet170	10.0.169.0	24	254	10.0.169.1	10.0.169.254	10.0.169.255
- Subnet171	10.0.170.0	24	254	10.0.170.1	10.0.170.254	10.0.170.255
- Subnet172	10.0.171.0	24	254	10.0.171.1	10.0.171.254	10.0.171.255
- Subnet173	10.0.172.0	24	254	10.0.172.1	10.0.172.254	10.0.172.255
- Subnet174	10.0.173.0	24	254	10.0.173.1	10.0.173.254	10.0.173.255
- Subnet175	10.0.174.0	24	254	10.0.174.1	10.0.174.254	10.0.174.255
- Subnet176	10.0.175.0	24	254	10.0.175.1	10.0.175.254	10.0.175.255
- Subnet177	10.0.176.0	24	254	10.0.176.1	10.0.176.254	10.0.176.255
- Subnet178	10.0.177.0	24	254	10.0.177.1	10.0.177.254	10.0.177.255
- Subnet179	10.0.178.0	24	254	10.0.178.1	10.0.178.254	10.0.178.255
- Subnet180	10.0.179.0	24	254	10.0.179.1	10.0.179.254	10.0.179.255
- Subnet181	10.0.180.0	24	254	10.0.180.1	10.0.180.254	10.0.180.255
- Subnet182	10.0.181.0	24	254	10.0.181.1	10.0.181.254	10.0.181.255
- Subnet183	10.0.182.0	24	254	10.0.182.1	10.0.182.254	10.0.182.255
- Subnet184	10.0.183.0	24	254	10.0.183.1	10.0.183.254	10.0.183.255
- Subnet185	10.0.184.0	24	254	10.0.184.1	10.0.184.254	10.0.184.255
- Subnet186	10.0.185.0	24	254	10.0.185.1	10.0.185.254	10.0.185.255
- Subnet187	10.0.186.0	24	254	10.0.186.1	10.0.186.254	10.0.186.255
- Subnet188	10.0.187.0	24	254	10.0.187.1	10.0.187.254	10.0.187.255
- Subnet189	10.0.188.0	24	254	10.0.188.1	10.0.188.254	10.0.188.255
- Subnet190	10.0.189.0	24	254	10.0.189.1	10.0.189.254	10.0.189.255
- Subnet191	10.0.190.0	24	254	10.0.190.1	10.0.190.254	10.0.190.255
- Subnet192	10.0.191.0	24	254	10.0.191.1	10.0.191.254	10.0.191.255
- Subnet193	10.0.192.0	24	254	10.0.192.1	10.0.192.254	10.0.192.255
- Subnet194	10.0.193.0	24	254	10.0.193.1	10.0.193.254	10.0.193.255
- Subnet195	10.0.194.0	24	254	10.0.194.1	10.0.194.254	10.0.194.255
- Subnet196	10.0.195.0	24	254	10.0.195.1	10.0.195.254	10.0.195.255
- Subnet197	10.0.196.0	24	254	10.0.196.1	10.0.196.254	10.0.196.255
- Subnet198	10.0.197.0	24	254	10.0.197.1	10.0.197.254	10.0.197.255
- Subnet199	10.0.198.0	24	254	10.0.198.1	10.0.198.254	10.0.198.255
- Subnet200	10.0.199.0	24	254	10.0.199.1	10.0.199.254	10.0.199.255
- Subnet201	10.0.200.0	24	254	10.0.200.1	10.0.200.254	10.0.200.255
- Subnet202	10.0.201.0	24	254	10.0.201.1	10.0.201.254	10.0.201.255
- Subnet203	10.0.202.0	24	254	10.0.202.1	10.0.202.254	10.0.202.255
- Subnet204	10.0.203.0	24	254	10.0.203.1	10.0.203.254	10.0.203.255
- Subnet205	10.0.204.0	24	254	10.0.204.1	10.0.204.254	10.0.204.255
- Subnet206	10.0.205.0	24	254	10.0.205.1	10.0.205.254	10.0.205.255
- Subnet207	10.0.206.0	24	254	10.0.206.1	10.0.206.254	10.0.206.255
- Subnet208	10.0.207.0	24	254	10.0.207.1	10.0.207.254	10.0.207.255
- Subnet209	10.0.208.0	24	254	10.0.208.1	10.0.208.254	10.0.208.255
- Subnet210	10.0.209.0	24	254	10.0.209.1	10.0.209.254	10.0.209.255
- Subnet211	10.0.210.0	24	254	10.0.210.1	10.0.210.254	10.0.210.255
- Subnet212	10.0.211.0	24	254	10.0.211.1	10.0.211.254	10.0.211.255
- Subnet213	10.0.212.0	24	254	10.0.212.1	10.0.212.254	10.0.212.255
- Subnet214	10.0.213.0	24	254	10.0.213.1	10.0.213.254	10.0.213.255
- Subnet215	10.0.214.0	24	254	10.0.214.1	10.0.214.254	10.0.214.255
- Subnet216	10.0.215.0	24	254	10.0.215.1	10.0.215.254	10.0.215.255
- Subnet217	10.0.216.0	24	254	10.0.216.1	10.0.216.254	10.0.216.255
- Subnet218	10.0.217.0	24	254	10.0.217.1	10.0.217.254	10.0.217.255
- Subnet219	10.0.218.0	24	254	10.0.218.1	10.0.218.254	10.0.218.255
- Subnet220	10.0.219.0	24	254	10.0.219.1	10.0.219.254	10.0.219.255
- Subnet221	10.0.220.0	24	254	10.0.220.1	10.0.220.254	10.0.220.255
- Subnet222	10.0.221.0	24	254	10.0.221.1	10.0.221.254	10.0.221.255
- Subnet223	10.0.222.0	24	254	10.0.222.1	10.0.222.254	10.0.222.255
- Subnet224	10.0.223.0	24	254	10.0.223.1	10.0.223.254	10.0.223.255
- Subnet225	10.0.224.0	24	254	10.0.224.1	10.0.224.254	10.0.224.255
- Subnet226	10.0.225.0	24	254	10.0.225.1	10.0.225.254	10.0.225.255
- Subnet227	10.0.226.0	24	254	10.0.226.1	10.0.226.254	10.0.226.255
- Subnet228	10.0.227.0	24	254	10.0.227.1	10.0.227.254	10.0.227.255
- Subnet229	10.0.228.0	24	254	10.0.228.1	10.0.228.254	10.0.228.255
- Subnet230	10.0.229.0	24	254	10.0.229.1	10.0.229.254	10.0.229.255
- Subnet231	10.0.230.0	24	254	10.0.230.1	10.0.230.254	10.0.230.255
- Subnet232	10.0.231.0	24	254	10.0.231.1	10.0.231.254	10.0.231.255
- Subnet233	10.0.232.0	24	254	10.0.232.1	10.0.232.254	10.0.232.255
- Subnet234	10.0.233.0	24	254	10.0.233.1	10.0.233.254	10.0.233.255
- Subnet235	10.0.234.0	24	254	10.0.234.1	10.0.234.254	10.0.234.255
- Subnet236	10.0.235.0	24	254	10.0.235.1	10.0.235.254	10.0.235.255
- Subnet237	10.0.236.0	24	254	10.0.236.1	10.0.236.254	10.0.236.255
- Subnet238	10.0.237.0	24	254	10.0.237.1	10.0.237.254	10.0.237.255
- Subnet239	10.0.238.0	24	254	10.0.238.1	10.0.238.254	10.0.238.255
- Subnet240	10.0.239.0	24	254	10.0.239.1	10.0.239.254	10.0.239.255
- Subnet241	10.0.240.0	24	254	10.0.240.1	10.0.240.254	10.0.240.255
- Subnet242	10.0.241.0	24	254	10.0.241.1	10.0.241.254	10.0.241.255
- Subnet243	10.0.242.0	24	254	10.0.242.1	10.0.242.254	10.0.242.255
- Subnet244	10.0.243.0	24	254	10.0.243.1	10.0.243.254	10.0.243.255
- Subnet245	10.0.244.0	24	254	10.0.244.1	10.0.244.254	10.0.244.255
- Subnet246	10.0.245.0	24	254	10.0.245.1	10.0.245.254	10.0.245.255
- Subnet247	10.0.246.0	24	254	10.0.246.1	10.0.246.254	10.0.246.255
- Subnet248	10.0.247.0	24	254	10.0.247.1	10.0.247.254	10.0.247.255
- Subnet249	10.0.248.0	24	254	10.0.248.1	10.0.248.254	10.0.248.255
- Subnet250	10.0.249.0	24	254	10.0.249.1	10.0.249.254	10.0.249.255
- Subnet251	10.0.250.0	24	254	10.0.250.1	10.0.250.254	10.0.250.255
- Subnet252	10.0.251.0	24	254	10.0.251.1	10.0.251.254	10.0.251.255
- Subnet253	10.0.252.0	24	254	10.0.252.1	10.0.252.254	10.0.252.255
- Subnet254	10.0.253.0	24	254	10.0.253.1	10.0.253.254	10.0.253.255
- Subnet255	10.0.254.0	24	254	10.0.254.1	10.0.254.254	10.0.254.255
- Subnet256	10.0.255.0	24	254	10.0.255.1	10.0.255.254	10.0.255.255











   

---------------------------------------------------------------------------------------------------------------------


















--------------------------------------------------------------------------------------------------------------
few good links
--------------------------------------------------------------------------------------------------------------

https://www.nicksantamaria.net/post/how-to-peer-vpcs-with-terraform/

https://github.com/C2Devel/terraform-examples/tree/master/cases


https://www.techtransit.org/set-up-aws-ec2-cli-tools-on-centos-rhel-linux-or-mac-os-x/


https://techoral.com/blog/java/install-openjdk-8-linux.html


https://alexharv074.github.io/2019/11/23/adventures-in-the-terraform-dsl-part-x-templates.html#introduction


https://thirdiron.com/one-step-beyond-intro-tutorials-configure-terraform-server-https-ssl/


# Jinja templating
https://ttl255.com/jinja2-tutorial-part-1-introduction-and-variable-substitution/
-----------------------------------------------------------------------------------------------------------------
