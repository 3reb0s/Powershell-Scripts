# Enable TLS 1.2 for the current PowerShell session
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Download the script and store it in a temporary file
$tempFile = "$env:TEMP\wintrust.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/3reb0s/Powershell-Scripts/refs/heads/main/wintrust.ps1' -OutFile $tempFile

# Execute the downloaded script
& $tempFile

# Optionally, clean up by removing the downloaded script file
Remove-Item -Path $tempFile -Force

# Download the script and store it in a temporary file
$tempFile = "$env:TEMP\tls_cipher.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/3reb0s/Powershell-Scripts/refs/heads/main/TLS_Cipher.ps1' -OutFile $tempFile

# Execute the downloaded script
& $tempFile


# Optionally, clean up by removing the downloaded script file
Remove-Item -Path $tempFile -Force

# Download the script and store it in a temporary file
$tempFile = "$env:TEMP\TLS_ENUM_LOCAL.ps1"
Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/3reb0s/Powershell-Scripts/refs/heads/main/TLS_EMUM_LOCAL.ps1' -OutFile $tempFile

# Execute the downloaded script
& $tempFile


# Optionally, clean up by removing the downloaded script file
Remove-Item -Path $tempFile -Force
