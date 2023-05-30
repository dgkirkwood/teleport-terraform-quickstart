packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


source "amazon-ebs" "windc" {
  ami_name      = var.ami_name
  instance_type = "t3.medium"
  region        = var.region
  vpc_id = var.vpc_id
  subnet_id = var.subnet_id
  associate_public_ip_address = true
  force_deregister = true
  force_delete_snapshot = true
  source_ami_filter {
    filters = {
      name                = "Windows_Server-2019-English-Full-Base-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["801119661308"]
  }
  communicator = "winrm"
  winrm_username = "Administrator"
  winrm_password = "Teleport1234"
  user_data_file = "bootstrap_win.txt"
}

build {
  name    = "packer-win-dc"
  sources = [
    "source.amazon-ebs.windc"
  ]
  provisioner "powershell" {
    inline = [
      "Rename-Computer -NewName '${var.hostname}'"
    ]
  }
  provisioner "windows-restart" {
  }
  provisioner "powershell" {
    inline = [
      "Import-Module ADDSDeployment",
      "$password = ConvertTo-SecureString ${var.admin_password} -AsPlainText -Force",
      "Add-WindowsFeature -name ad-domain-services -IncludeManagementTools",
      "Install-ADDSForest -CreateDnsDelegation:$false -DomainMode Win2012R2 -DomainName ${var.active_directory_domain_name} -DomainNetbiosName ${var.active_directory_netbios_name} -ForestMode Win2012R2 -InstallDns:$true -SafeModeAdministratorPassword $password -Force:$true"
    ]
  }
  provisioner "windows-restart" {
  }
  provisioner "powershell" {
    inline = [
      "Install-WindowsFeature Adcs-Cert-Authority -IncludeManagementTools",
      "Install-AdcsCertificationAuthority -CAType EnterpriseRootCa -CACommonName ${var.virtual_machine_fqdn} -ValidityPeriod Years -ValidityPeriodUnits 3  -Force"
    ]
  }
  
}
