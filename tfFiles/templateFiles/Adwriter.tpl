<script>
winrm quickconfig -q & winrm set winrm/config/winrm @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"} & winrm set winrm/config/service @{AllowUnencrypted="true"} > c:\userDatatStatus.txt
</script>

<powershell>
echo "Status before userdata powershell executed" | Out-File C:\userDatabeforepowershellstatus.txt
netsh advfirewall firewall add rule name="WinRM in http" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
netsh advfirewall firewall add rule name="WinRM in https" protocol=TCP dir=in profile=any localport=5986 remoteip=any localip=any action=allow
netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow
$admin = [ADSI]("WinNT://./administrator, user")
$admin.SetPassword("${ADMIN_PASSWORD_WINSERVER}")
echo "Status after userdata powershell executed" | Out-File C:\userDataafterpowershellstatus.txt
</powershell>
