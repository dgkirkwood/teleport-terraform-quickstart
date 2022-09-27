<powershell>
Rename-Computer -NewName ${windows_hostname} -Force
$dc = ${active_directory_domain_name}
$pw = ${admin_password}
$usr = ${admin_user}
$secPw = ConvertTo-SecureString $pw -AsPlainText -Force
$creds = New-Object System.Management.Automation.PSCredential($usr,$secPw)
Add-Computer -DomainName $dc -Credential $creds -restart -force -verbose
</powershell>