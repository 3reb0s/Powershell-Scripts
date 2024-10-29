# Enable SMB Signing
Set-SmbServerConfiguration -RequireSecuritySignature $true -Force
Set-SmbClientConfiguration -RequireSecuritySignature $true -Force

# Define registry path for NetBIOS setting
$netbiosRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces"

# Disable NBT-NS (NetBIOS over TCP/IP) on all interfaces
if (Test-Path $netbiosRegistryPath) {
    Get-ChildItem -Path $netbiosRegistryPath | ForEach-Object {
        New-ItemProperty -Path $_.PSPath -Name 'NetbiosOptions' -Value 2 -PropertyType DWORD -Force | Out-Null
    }
    Write-Output "NBT-NS has been disabled by setting NetbiosOptions to 2 on all interfaces."
} else {
    Write-Output "NetBT Parameters registry path does not exist."
}

# Disable mDNS
$mdnsRegistryPath = "HKLM:\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters"
$valueName = "EnableMDNS"

# Check if the mDNS registry path exists; if not, create it
if (!(Test-Path $mdnsRegistryPath)) {
    New-Item -Path $mdnsRegistryPath -Force | Out-Null
}

# Set the registry value to disable mDNS
New-ItemProperty -Path $mdnsRegistryPath -Name $valueName -PropertyType DWORD -Value 0 -Force | Out-Null

Write-Output "mDNS has been disabled by setting EnableMDNS to 0 in the registry."
