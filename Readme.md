
 We are trying to implement pipeline using AWS teraafrom

l. Generate ssh key from aws portal by name Vpn.public in portal and save its private key  with name Vpn.public.ppk in your unix host from where you are running terraform scripts in a directory tfFiles/keyDir/Vpn.public.ppk

Note: do not change file names like Vpn.public in aws and Vpn.public.ppk for private key when saving private key from aws.


2. Copy Vpn.public.ppk in tfFiles/keyDir/Vpn.public.ppk


3. run script tfFiles/unixScripts
 Note this script assume you are using RHEL7 server as terraform server from where you will run terraform apply.
 elseyou can download pem file from AWS or use windows to convert ppk to pem
 .ppk is for putty and .pem is to login from unix to unix






























https://github.com/C2Devel/terraform-examples/tree/master/cases


https://www.techtransit.org/set-up-aws-ec2-cli-tools-on-centos-rhel-linux-or-mac-os-x/


https://techoral.com/blog/java/install-openjdk-8-linux.html


https://alexharv074.github.io/2019/11/23/adventures-in-the-terraform-dsl-part-x-templates.html#introduction



# Jinja templating
https://ttl255.com/jinja2-tutorial-part-1-introduction-and-variable-substitution/



If you want to list all the files currently being tracked under the branch master, you could use this command:
git ls-tree -r master --name-only

If you want a list of files that ever existed (i.e. including deleted files):
git log --pretty=format: --name-only --diff-filter=A | sort - | sed '/^$/d'
----------------------------------------------------------------------------------------


1l. Generate ssh key from aws portal by name Vpn.public	in portal and save it with name Vpn.public.ppk in your desktop.
2. copy  Vpn.public.ppk in /tfFiles/keyDir/Vpn.public.ppk (already have entry in .gitignore file
