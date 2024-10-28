# Path to the registry key
$registryPath = 'HKLM:\Software\Microsoft\Cryptography\Wintrust\Config'

# Create the key if it doesn't exist
if (!(Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force | Out-Null
}

# Set the EnableCertPaddingCheck value to 1
New-ItemProperty -Path $registryPath -Name 'EnableCertPaddingCheck' -Value 1 -PropertyType 'DWord' -Force | Out-Null
