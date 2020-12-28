variable "AWS_REGION" {
    description = "Region Name where you what your data center"
    default = "us-east-1"
}

variable "ENABLE_DNS_HOSTNAMES" {
    description = "this needs to be enables when you plan to use route 53 for internal network"
    default = "true"
}

variable "ENABLE_DNS_SUPPORT" {
    description = "this needs to be enables when you plan to use route 53 for internal network"
    default = "true"
}


variable "VPC_CIDR_BLOCK" {
    description = "cidr_block for your vpc/Network"
    default = "10.0.0.0/21"
}

variable "LOCATION" {
    description = "Full anme of Your location of Data Center"
    default = "NVirginia"
}

variable "PUBLIC_SUBNET_A_CIDR_BLOCK" {
    default = "10.0.0.0/24"
}

variable "PUBLIC_SUBNET_B_CIDR_BLOCK" {
    default = "10.0.1.0/24"
}

variable "PVT_SUBNET_A_CIDR_BLOCK" {
    default = "10.0.4.0/24"
}

variable "PVT_SUBNET_B_CIDR_BLOCK" {
    default = "10.0.5.0/24"
}

variable "HOMEIPADDRESS"{ 
    default = ["106.215.107.200/32"]
}

variable "DOMAINNAME" {
    default = "amitsuneja.xyz"
}

variable "MYENVTYPE" {
    default = "Production"
}

variable "DOMAINADMINPASSWORD" {
   default = "Welcome@1234"
}

variable "DOMAINSIZE" {
   default = "Small"
}

variable "COUNTOFDC" {
   default = "2"
}

variable "DNSSERVERFORVPC" {
   default = "10.0.0.2"
}

variable "BASIONHOST_PRIVATE_IP" {
   default = "10.0.1.10"
}

variable "MasterDB_INST_PRIVATE_IP" {
   default = "10.0.4.10"
}


variable "SlaveDB_INST_PRIVATE_IP" {
   default = "10.0.5.10"
}

variable "CENTOS7_CUSTOMIZED_AMI" {
   default = "ami-ceb15ab3"
}

variable "NAT_INST_TYPE" {
   default = "t2.micro"
}


variable "NAT_INST_KEY_NAME" {
   default = "Vpn.public"
}

variable "S3_BUCKET_NAME" {
   default = "amitsuneja.xyz-mysql-backup"
}

variable "DNSNAME" {
   default = "ns1"
}

variable "DNS1IP-PATH" {
      default = "/tmp/dns1ip.txt"
}

variable "DNS1IP-PATH-REV" {
      default = "/tmp/dns1ip_reverse.txt"
}

variable "DNS2NAME-PATH" {
   default = "/tmp/dns2name.txt"
}

variable "DNS2IP-PATH" {
      default = "/tmp/dns2ip.txt"
}

variable "DNS2IP-PATH-REV" {
      default = "/tmp/dns2ip_reverse.txt"
}

variable "ADMIN_PASSWORD_WINSERVER" {
      default = "Welcome@0987"
}

variable "WINDOWS2012BASER2AMI" {
      default = "ami-c951acb4"
}

variable "ADWRITER_INST_PRIVATE_IP" {
      default = "10.0.0.10"
}

variable "MYREPUSER" {
      default = "myrepuser"
}

variable "MYREPPASS" {
      default = "myreppass"
}

variable "NEWROOT" {
      default = "newroot"
}

variable "NEWROOTPASS" {
      default = "newrootpass"
} 
