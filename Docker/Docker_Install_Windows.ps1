# Step 1: Install WSL 2
wsl --install -d Ubuntu
# Optional: Wait for WSL to install properly
Start-Sleep -Seconds 30

# Step 2: Install Docker Desktop (latest)
$dockerInstaller = "$env:TEMP\DockerDesktopInstaller.exe"
Invoke-WebRequest -Uri "https://desktop.docker.com/win/main/amd64/Docker Desktop Installer.exe" -OutFile $dockerInstaller
Start-Process -FilePath $dockerInstaller -ArgumentList "install", "--quiet" -Wait