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


7. Must Pay attention to Bastion.tf - It shows how to connect ansible to terraform. And also show how how we read  .tpl(template file as data and passwd it as user data to new server(tpl file contain  script/commands we cant to execute on host once it got created)

8. Must Pay attention to  how we picked variable from teraaform and passed then to data -this data will be used as userdata
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
