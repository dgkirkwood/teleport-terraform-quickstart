Invoke-WebRequest -Uri https://github.com/gravitational/teleport/releases/download/v12.0.0-passwordless-windows/teleport-windows-auth-setup-v12.0.0-amd64.zip -OutFile C:\Users\Administrator\Downloads\teleport.zip
Expand-Archive -Path "C:\Users\Administrator\Downloads\teleport.zip" -DestinationPath "C:\Users\Administrator\Downloads\"
cd "C:\Users\Administrator\Downloads"
.\teleport-windows-auth-setup.exe install --cert=C:\Users\Administrator\Downloads\teleport.cer