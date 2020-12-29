#!/bin/bash
DATED=`date +'%m-%d-%Y'`__`date +"%T"`
logFile="/tmp/userdata.out" 
echo " " >> $logFile
echo "running script at $DATED" > $logFile
echo " " >> $logFile
echo "_____________________________"  >> $logFile
echo " " >> $logFile
echo "Installing ansible2...."  >> $logFile
amazon-linux-extras install -y ansible2 >> $logFile
echo " " >> $logFile
echo "_____________________________"  >> $logFile
echo "running yum update -y" >> $logFile
echo " " >> $logFile
yum update -y >> $logFile
echo " " >> $logFile
echo "_____________________________"  >> $logFile
echo "creating cls softlink for you" >> $logFile
echo " " >> $logFile
ln -s /usr/bin/clear /usr/bin/cls >> $logFile
echo " " >> $logFile
echo "_____________________________"  >> $logFile
