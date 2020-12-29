#!/bin/bash
DATED=`date +'%m-%d-%Y'`__`date +"%T"`
logFile="/tmp/userdata.out" 
echo "running script at $DATED" > $logFile
echo "_____________________________"  >> $logFile
echo "Installing ansible2...."  >> $logFile
amazon-linux-extras install -y ansible2 >> $logFile
echo "running yum update -y" >> $logFile
yum update -y >> $logFile
echo "cheating cls softlink for you" >> $logFile
ln -s /usr/bin/clear /usr/bin/cls >> $logFile
