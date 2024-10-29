#Set SMB Signing
Set-SmbServerConfiguration -RequireSecuritySignature $true
Set-SmbServerConfiguration -RequireSecuritySignature $true

#Disable NBT-NS 
New-ItemProperty -Path $registryPath -Name 'EnableNetbios' -Value 0 -PropertyType DWord -Force | Out-Null

#Disable MDNS 
# Define the registry path and value name
$registryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
$valueName = "EnableMDNS"

# Check if the registry path exists; if not, create it
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the registry value to disable mDNS
New-ItemProperty -Path $registryPath -Name $valueName -PropertyType DWORD -Value 0 -Force | Out-Null
