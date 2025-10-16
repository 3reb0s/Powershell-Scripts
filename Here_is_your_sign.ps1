# Server side: require + enable signing
Set-SmbServerConfiguration  -RequireSecuritySignature $true -EnableSecuritySignature $true -Force

# Client side: require + enable signing
Set-SmbClientConfiguration  -RequireSecuritySignature $true -EnableSecuritySignature $true

#Service-Restart
Restart-Service lanmanserver -Force
Restart-Service lanmanworkstation -Force
