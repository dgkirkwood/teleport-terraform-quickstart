Invoke-WebRequest -Uri https://cdn.teleport.dev/teleport-windows-auth-setup-v13.1.1-amd64.exe -OutFile C:\Users\Administrator\Downloads\teleport_windows.exe
cd "C:\Users\Administrator\Downloads"
.\teleport_windows.exe install --cert=C:\Users\Administrator\Downloads\teleport.cer