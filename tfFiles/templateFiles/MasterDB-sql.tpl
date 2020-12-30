#!/bin/bash
test=1
mkdir -p /myscripts
ln -s /usr/bin/clear /usr/bin/cls
sudo hostnamectl set-hostname MasterDB-sql
while [ $test -ne 0 ]
do
  ping -c 1 -w 30 google.com >> /myscripts/pingtest.txt
   if [ $? -eq  0 ]
   then
             test=0
             echo "0" >> /myscripts/pingtest.txt
   else
             test=1
             echo "1"  >> /myscripts/pingtest.txt
   fi
done
echo "Adding Required softwared to Join Domain" > /myscripts/InstallingRpms.out 2>&1
echo "yum -y install realmd krb5-workstation oddjob oddjob-mkhomedir sssd samba-common-tools expect" > /myscripts/InstallingRpms.sh
sh -x /myscripts/InstallingRpms.sh > /myscripts/InstallingRpms.out 2>&1
echo "set DOMAINNAME ${DOMAINNAME}" > /myscripts/DomainJoin.exp 2>&1
echo "set DOMAINPASSWORD ${DOMAINADMINPASSWORD}" >> /myscripts/DomainJoin.exp 2>&1
echo "spawn sudo realm join -U administrator@${DOMAINNAME} ${DOMAINNAME}" >> /myscripts/DomainJoin.exp 2>&1
echo "expect -exact \"Password for administrator@${DOMAINNAME}:\" " >> /myscripts/DomainJoin.exp 2>&1
echo "send -- "\${DOMAINADMINPASSWORD}\\r"" >> /myscripts/DomainJoin.exp 2>&1
echo "expect eof" >> /myscripts/DomainJoin.exp 2>&1
echo "changing permission of DomainJoin.exp" > /myscripts/DomainJoin.out 2>&1
chmod 755 /myscripts/DomainJoin.exp >> /myscripts/DomainJoin.out 2>&1
echo "Executing /myscripts/DomainJoin.exp script" >> /myscripts/DomainJoin.out 2>&1
/bin/expect /myscripts/DomainJoin.exp >> /myscripts/DomainJoin.out 2>&1
echo "Welcome to ${DOMAINNAME} Domain" >> /myscripts/DomainJoin.out 2>&1
yum install -y  mariadb-server > /myscripts/InstallingMariaDB.out 2>&1
systemctl enable mariadb >> /myscripts/InstallingMariaDB.out 2>&1
cp -p /etc/my.cnf /etc/my.cnf.backup.orignal
sed -i '/\[mysqld_safe\]/i server-id = 1' /etc/my.cnf
sed -i '/\[mysqld_safe\]/i binlog_format= row' /etc/my.cnf
sed -i '/\[mysqld_safe\]/i log_bin' /etc/my.cnf
sed -i '/\[mysqld_safe\]/i log-basename = master' /etc/my.cnf
systemctl start mariadb >> /myscripts/InstallingMariaDB.out 2>&1
test=1
while [ $test -ne 0 ]
do
   fdisk -l | grep "/dev/xvdi" && fdisk -l  | grep "/dev/xvdh"
        if [ $? -eq  0 ]
        then
             test=0
             echo "disk still not found" >> /tmp/mkfs.out
        else
             test=1
        fi
done
echo "mkdir /datavol0001" > /myscripts/Preparedisk.sh
echo "mkdir /datavol0002" >> /myscripts/Preparedisk.sh
echo "mkfs -t ext4 /dev/xvdh" >> /myscripts/Preparedisk.sh
echo "mkfs -t ext4 /dev/xvdi" >> /myscripts/Preparedisk.sh
echo "mount /dev/xvdh /datavol0001" >> /myscripts/Preparedisk.sh
echo "mount /dev/xvdi /datavol0002" >> /myscripts/Preparedisk.sh
sh -x /myscripts/Preparedisk.sh > /myscripts/Preparedisk.sh.out 2>&1 
echo "/dev/xvdh       /datavol0001    ext4    defaults         0 0" >> /etc/fstab
echo "/dev/xvdi       /datavol0002    ext4    defaults         0 0" >> /etc/fstab
mysql -uroot -s -N -e "create user '${MYREPUSER}'@'%' identified by '${MYREPPASS}'" > /myscripts/createmaster.out 2>&1
mysql -uroot -s -N -e "create user '${NEWROOT}'@'%' identified by '${NEWROOTPASS}'" > /myscripts/createmaster.out 2>&1
mysql -uroot -s -N -e "select host,user,Password FROM mysql.user where user='${MYREPUSER}'" >> /myscripts/createmaster.out 2>&1
mysql -uroot -s -N -e "select host,user,Password FROM mysql.user where user='${NEWROOT}'" >> /myscripts/createmaster.out 2>&1
mysql -uroot -s -N -e "GRANT REPLICATION SLAVE ON *.* TO '${MYREPUSER}'" >> /myscripts/createmaster.out 2>&1
mysql -uroot -s -N -e "GRANT ALL PRIVILEGES ON  *.* TO '${NEWROOT}'@'%'" >> /myscripts/createmaster.out 2>&1
mysql -uroot -s -N -e "FLUSH PRIVILEGES"  >> /myscripts/createmaster.out 2>&1
echo "Following are username and passwords created in database" >> /myscripts/createmaster.out 2>&1
echo "${MYREPUSER} -- ${MYREPPASS} , ${NEWROOT} -- ${NEWROOTPASS}" >> /myscripts/createmaster.out 2>&1
