    %{ for fruit in fruits ~}
  yum install -y  ${ fruit }
    %{ endfor ~}
  yum update -y
  ln -s /usr/bin/clear /usr/bin/cls
