output "windowsPassword" {
  value = rsadecrypt(aws_instance.windows-2019.password_data, file("~/.ssh/id_rsa"))
}

output "dc_public_ip" {
  value = aws_instance.windows.public_ip
}

output "linux_public_ip" {
  value = aws_instance.target_nodes.public_ip
}
  
output "windows_public_ip" {
  value = aws_instance.windows-2019.public_ip
}