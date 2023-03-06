packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}


source "amazon-ebs" "winnonad" {
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
  name    = "packer-win-non-ad"
  sources = [
    "source.amazon-ebs.winnonad"
  ]
  provisioner "file" {
    source      = "teleport.cer"
    destination = "C:/Users/Administrator/Downloads/teleport.cer"
  }
  provisioner "powershell" {
    inline = [
      "Rename-Computer -NewName '${var.hostname}'"
    ]
  }
  provisioner "windows-restart" {
  }
  provisioner "powershell" {
    script = "teleport-install.ps1"
  }
  provisioner "windows-restart" {
  }

  
  // provisioner "powershell" {
  //   inline = [
  //     "$AD_USER_NAME='Teleport Service Account'",
  //     "$SAM_ACCOUNT_NAME='svc-teleport'",
  //     "$DOMAIN_NAME=(Get-ADDomain).DNSRoot",
  //     "$DOMAIN_DN=$((Get-ADDomain).DistinguishedName)",
  //     "New-ADObject -Name 'Teleport' -Type 'container' -Path 'CN=CDP,CN=Public Key Services,CN=Services,CN=Configuration,$DOMAIN_DN'",
  //     # Gives Teleport the ability to create LDAP containers in the CDP container.
  //     "dsacls 'CN=CDP,CN=Public Key Services,CN=Services,CN=Configuration,$DOMAIN_DN' /I:T /G '$($SAM_ACCOUNT_NAME):CC;container;'",
  //     # Gives Teleport the ability to create and delete cRLDistributionPoint objects in the CDP/Teleport container.
  //     "dsacls 'CN=Teleport,CN=CDP,CN=Public Key Services,CN=Services,CN=Configuration,$DOMAIN_DN' /I:T /G '$($SAM_ACCOUNT_NAME):CCDC;cRLDistributionPoint;'",
  //     # Gives Teleport the ability to write the certificateRevocationList property in the CDP/Teleport container.
  //     "dsacls 'CN=Teleport,CN=CDP,CN=Public Key Services,CN=Services,CN=Configuration,$DOMAIN_DN ' /I:T /G '$($SAM_ACCOUNT_NAME):WP;certificateRevocationList;'",
  //     # Gives Teleport the ability to create and delete certificationAuthority objects in the NTAuthCertificates container.
  //     "dsacls 'CN=NTAuthCertificates,CN=Public Key Services,CN=Services,CN=Configuration,$DOMAIN_DN' /I:T /G '$($SAM_ACCOUNT_NAME):CCDC;certificationAuthority;'",
  //     # Gives Teleport the ability to write the cACertificate property in the NTAuthCertificates container.
  //     "dsacls 'CN=NTAuthCertificates,CN=Public Key Services,CN=Services,CN=Configuration,$DOMAIN_DN' /I:T /G '$($SAM_ACCOUNT_NAME):WP;cACertificate;'",
  //     "$SAM_ACCOUNT_SID=(Get-ADUser -Identity $SAM_ACCOUNT_NAME).SID.Value"
  //   ]
  // }
  // provisioner "powershell" {
  //   inline = [
  //     "$BLOCK_GPO_NAME='Block teleport-svc Interactive Login'",
  //     "New-GPO -Name $BLOCK_GPO_NAME | New-GPLink -Target $DOMAIN_DN",

  //     "$DENY_SECURITY_TEMPLATE=@'
  //     [Unicode]
  //     Unicode=yes
  //     [Version]
  //     signature='$CHICAGO$'
  //     [Privilege Rights]
  //     SeDenyRemoteInteractiveLogonRight=*{0}
  //     SeDenyInteractiveLogonRight=*{0}
  //     '@ -f $SAM_ACCOUNT_SID",

  //     "$BLOCK_POLICY_GUID=((Get-GPO -Name $BLOCK_GPO_NAME).Id.Guid).ToUpper()",
  //     "$BLOCK_GPO_PATH='$env:SystemRoot\SYSVOL\sysvol\$DOMAIN_NAME\Policies\{$BLOCK_POLICY_GUID}\Machine\Microsoft\Windows NT\SecEdit'",
  //     "New-Item -Type Directory -Path $BLOCK_GPO_PATH",
  //     "New-Item -Path $BLOCK_GPO_PATH -Name 'GptTmpl.inf' -ItemType 'file' -Value $DENY_SECURITY_TEMPLATE"
  //   ]
  // }

}
