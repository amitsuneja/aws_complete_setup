## OutFile to show the script ran
echo "Status before Command executed" | Out-File C:\status.txt
$NewHostName = "adwriter"
Import-Module ServerManager
Add-WindowsFeature RSAT-ADDS-Tools
$domain = "AMITSUNEJA.xyz"
$password = "Welcome@1234" | ConvertTo-SecureString -asPlainText -Force
$username = "$domain\administrator" 
$credential = New-Object System.Management.Automation.PSCredential($username,$password)
Add-Computer -DomainName $domain -NewName $NewHostName -Credential $credential -Restart
## OutFile to show the script ran
echo "Status After Command executed" | Out-File -Append C:\status.txt
