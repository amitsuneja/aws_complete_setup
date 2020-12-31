# from .bashrc file
# Added Python3.6
export PATH=$PATH:/opt/rh/rh-python36/root/bin
###################################################
#AWS LOGIN
###################################################
export AWS_ACCESS_KEY=*****************************
export AWS_SECRET_KEY=*****************************
export AWS_DEFAULT_REGION=us-west-2
####################################################
#for AWS EC-tool to work Java is Must (what PATH OF JAVA? -JAVA binay = $JAVA_HOME/bin/Java
export EC2_BASE=/opt/ec-tool/
export EC2_HOME=$EC2_BASE/tools
export PATH=$PATH:$EC2_HOME/bin
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.161-2.b14.el7_4.x86_64
export EC2_URL=https://us-east-1.ec2.amazonaws.com
############################################################
#to generate lots of Terraform logs
export TF_LOG=TRACE
export TF_LOG_PATH=/tmp/terraform.log
####################################################
# To make sure ansible connect to newly created hosts without prompting anything
export ANSIBLE_HOST_KEY_CHECKING=False
####################################################
