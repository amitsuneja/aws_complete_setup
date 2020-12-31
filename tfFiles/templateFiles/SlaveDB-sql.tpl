#!/bin/bash
test=1
mkdir -p /myscripts
ln -s /usr/bin/clear /usr/bin/cls
sudo hostnamectl set-hostname SlaveDB-sql
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
echo "yum -y install nmap-ncat" >> /myscripts/InstallingRpms.sh
sh -x /myscripts/InstallingRpms.sh >> /myscripts/InstallingRpms.out 2>&1
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
echo "Welcome to ${DOMAINNAME} domain" >> /myscripts/DomainJoin.out 2>&1
yum install -y  mariadb-server > /myscripts/InstallingMariaDB.out 2>&1
systemctl enable mariadb >> /myscripts/InstallingMariaDB.out 2>&1
cp -p /etc/my.cnf /etc/my.cnf.backup.orignal
sed -i '/\[mysqld_safe\]/i server-id = 2' /etc/my.cnf
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
test=1
while [ $test -ne 0 ]
do
   nc -w 1 "${MasterDB_INST_PRIVATE_IP}" 3306 </dev/null
   if [ $? -eq  0 ]
   then
             test=0
   else
             test=1
   fi
done
mysql -uroot -s -N -e "CHANGE MASTER TO MASTER_HOST='${MasterDB_INST_PRIVATE_IP}',MASTER_USER='${MYREPUSER}',MASTER_PASSWORD='${MYREPPASS}',MASTER_PORT=3306,MASTER_CONNECT_RETRY=10" > /myscripts/CreateSlave.out 2>&1
mysql -uroot -s -N -e "FLUSH PRIVILEGES"  >> /myscripts/CreateSlave.out 2>&1
mysql -uroot -s -N -e "START SLAVE" >> /myscripts/CreateSlave.out 2>&1
mysql -uroot -s -N -e "Show Slave status\G" >> /myscripts/CreateSlave.out 2>&1
mysql -uroot -s -N -e "STOP SLAVE" >> /myscripts/CreateSlave.out 2>&1
mysql -uroot -s -N -e "FLUSH PRIVILEGES"  >> /myscripts/CreateSlave.out 2>&1
mysql -h "${MasterDB_INST_PRIVATE_IP}" -u"${NEWROOT}" -p"${NEWROOTPASS}" -s -N -e "RESET MASTER" >> /myscripts/CreateSlave.out 2>&1
mysql -h "${MasterDB_INST_PRIVATE_IP}" -u"${NEWROOT}" -p"${NEWROOTPASS}" -s -N -e "SHOW MASTER STATUS" >> /myscripts/CreateSlave.out 2>&1
mysql -uroot -s -N -e "RESET SLAVE" >> /myscripts/CreateSlave.out 2>&1
mysql -uroot -s -N -e "START SLAVE" >> /myscripts/CreateSlave.out 2>&1
echo "trying to connect to remote server using below" >> /myscripts/CreateSlave.out 2>&1
echo "${MYREPUSER} -- ${MYREPPASS} , ${NEWROOT} -- ${NEWROOTPASS}" >> /myscripts/CreateSlave.out 2>&1

