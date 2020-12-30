#!/bin/bash

ProdSlaveInstances=`aws ec2 describe-instances --region us-east-1 --filters Name=tag:Enviroment,Values="Production" --filters  Name=tag:Role,Values="sqlslave" | jq ".Reservations[].Instances[].InstanceId"`
echo $ProdSlaveInstances


for instance in $ProdSlaveInstances
do  
  volumes=`aws ec2 describe-volumes --region us-east-1 --filters Name=attachment.instance-id,Values="$instance" --filters Name=attachment.device,Values="/dev/sdi","/dev/sdh" | jq .Volumes[].VolumeId | sed 's/\"//g'`
  echo $volumes
  
      
  for volume in $volumes
  do
    echo Creating snapshot for $volume 
   # aws ec2 create-snapshot --region us-east-1 --volume-id $volume --description "ebs-backup-script"
  done
done
