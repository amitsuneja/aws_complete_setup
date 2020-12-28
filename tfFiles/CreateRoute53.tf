# This will create one hosted zones of type public with domain name amitsuneja.xyz  and 2 records in it NS and SOA.
# NS record - recordname amitsuneja.xyz contain list of named servers
# SOA record - Soa record for domain
resource "aws_route53_zone" "selected" {
 	name                = join("", [ var.DOMAINNAME, "."])
  	tags = {
                Name        = var.DOMAINNAME
    		Environment = var.MYENVTYPE
      }
}

#https://stackoverflow.com/questions/56372089/issues-with-iterating-over-list-or-set-of-elements-in-terraform
#The root problem here is that data.aws_subnet_ids.subnet_list.ids is a set value, rather than a list value, and 
# so its elements are not in a particular order and therefore cannot be accessed by numeric index into a list.
# 
#To use it as a list requires deciding on how to order the elements. In this case it seems that the ordering 
#isn't really important because the goal is just to create one instance per subnet, 
#so passing the set to the sort function should be sufficient to sort them lexically:
#

locals {
  nameOfDCs = join(".", [var.DNSNAME,var.DOMAINNAME])
}


resource "aws_route53_record" "DomainController1" {
        zone_id             = aws_route53_zone.selected.zone_id
        name                = local.nameOfDCs
        type                = "A"
        ttl                 = "300"
        records             = aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses
}


resource "aws_route53_record" "ldap0001" {
        zone_id             = aws_route53_zone.selected.zone_id
        name                = join(".", [ "_ldap._tcp", var.DOMAINNAME])
        type                = "SRV"
        ttl                 = "300"
        records             = toset([join(" ", ["1 50 389"], [local.nameOfDCs])])
}


resource "aws_route53_record" "ldap0002" {
        zone_id             = aws_route53_zone.selected.zone_id
        name                = join(".", [ "_ldap._tcp.dc._msdcs", var.DOMAINNAME])
        type                = "SRV"
        ttl                 = "300"
        records             = toset([join(" ", ["1 50 389"], [local.nameOfDCs])])
}



resource "aws_route53_record" "ldap0003" {
        zone_id             = aws_route53_zone.selected.zone_id
        name                = join(".", [ "_ldap._tcp.pdc._msdcs", var.DOMAINNAME])
        type                = "SRV"
        ttl                 = "300"
        records             = toset([join(" ", ["1 50 389"], [local.nameOfDCs])])
}



resource "aws_route53_record" "ldap0004" {
       zone_id             = aws_route53_zone.selected.zone_id
       name                = join(".", [ "_ldap._tcp.gc._msdcs", var.DOMAINNAME])
       type                = "SRV"
       ttl                 = "300"
       records             = toset([join(" ", ["1 50 3268"], [local.nameOfDCs])])
}

resource "aws_route53_record" "ldap0005" {
       zone_id             = aws_route53_zone.selected.zone_id
       name                = join(".", [ "_gc._tcp", var.DOMAINNAME])
       type                = "SRV"
       ttl                 = "300"
       records             = toset([join(" ", ["1 50 3268"], [local.nameOfDCs])])
}




resource "aws_route53_record" "ldap0006" {
       zone_id             = aws_route53_zone.selected.zone_id
       name                = join(".", [ "_kerberos._tcp", var.DOMAINNAME])
       type                = "SRV"
       ttl                 = "300"
       records             = toset([join(" ", ["1 50 88"], [local.nameOfDCs])])
}

resource "aws_route53_record" "ldap0007" {
       zone_id             = aws_route53_zone.selected.zone_id
       name                = join(".", [ "_kerberos._udp", var.DOMAINNAME])
       type                = "SRV"
       ttl                 = "300"
       records             = toset([join(" ", ["1 50 88"], [local.nameOfDCs])])
}


resource "aws_route53_record" "ldap0008" {
       zone_id             = aws_route53_zone.selected.zone_id
       name                = join(".", [ "_kpasswd._tcp", var.DOMAINNAME])
       type                = "SRV"
       ttl                 = "300"
       records             = toset([join(" ", ["1 50 464"], [local.nameOfDCs])])
}


resource "aws_route53_record" "ldap0009" {
       zone_id             = aws_route53_zone.selected.zone_id
       name                = join(".", [ "_kpasswd._udp", var.DOMAINNAME])
       type                = "SRV"
       ttl                 = "300"
       records             = toset([join(" ", ["1 50 464"], [local.nameOfDCs])])
}



resource "aws_route53_record" "ldap0010" {
        zone_id             = aws_route53_zone.selected.zone_id
        name                = var.DOMAINNAME
        type                = "A"
        ttl                 = "300"
        records             = aws_directory_service_directory.MyActiveDirectory.dns_ip_addresses
}

resource "aws_route53_zone" "MyPvtZoneDB" {
        comment             = "ReversePrivateDNSZone"

  name = format("%s.%s.in-addr.arpa.",element( split(".", aws_vpc.MyVpc.cidr_block) ,1),
      element( split(".", aws_vpc.MyVpc.cidr_block) ,0),)
}


#resource "aws_route53_record" "RevRecDC1" {
#  zone_id = aws_route53_zone.MyPvtZoneDB.id
#  name = "${var.DNS1IPREV}"
#  type = "PTR"
#  ttl = "300"
#  records = ["${var.DNS1NAME}.${var.DOMAINNAME}"]
#}



#resource "aws_route53_record" "RevRecDC2" {
#  zone_id = "${aws_route53_zone.MyPvtZoneDB.id}"
#  name = "${var.DNS2IPREV}"
#  type = "PTR"
#  ttl = "300"
#  records = ["${var.DNS2NAME}.${var.DOMAINNAME}"]
#}
#
#
#
#
#
#
#
#
#
#
#resource "aws_route53_record" "masterdb-sql" {
#        zone_id             = "${aws_route53_zone.selected.zone_id}"
#        name                = "masterdb-sql.${aws_route53_zone.selected.name}"
#        type                = "A"
#        ttl                 = "300"
#        records             = ["${var.MasterDB_INST_PRIVATE_IP}"]
#}
#
#
#resource "aws_route53_record" "slavedb-sql" {
#        zone_id             = "${aws_route53_zone.selected.zone_id}"
#        name                = "slavedb-sql.${aws_route53_zone.selected.name}"
#        type                = "A"
#        ttl                 = "300"
#        records 	    = ["${var.SlaveDB_INST_PRIVATE_IP}"]
#}
#
#resource "aws_route53_record" "basionhost" {
#        zone_id             = "${aws_route53_zone.selected.zone_id}"
#        name                = "basionhost.${aws_route53_zone.selected.name}"
#        type                = "A"
#        ttl                 = "300"
#        records             = ["${var.BASIONHOST_PRIVATE_IP}"]
#}
#
#resource "aws_route53_record" "Adwriter" {
#        zone_id             = "${aws_route53_zone.selected.zone_id}"
#        name                = "Adwriter.${aws_route53_zone.selected.name}"
#        type                = "A"
#        ttl                 = "300"
#        records             = ["${var.ADWRITER_INST_PRIVATE_IP}"]
#}
#
