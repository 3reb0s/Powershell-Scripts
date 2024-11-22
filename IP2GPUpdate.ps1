$IPFilePath = "PATH HERE"
$IPAddresses = Get-Content -Path $IPFilePath

$ComputerNames = @()

foreach ($IPAddress in $IPAddresses) {
    $nslookupResult = nslookup $IPAddress

    # Extract the hostname (computer name) from the nslookup output
    $hostname = ($nslookupResult | Select-String "Name:").ToString().Split(":")[1].Trim()

    if ($hostname) {
        $ComputerNames += $hostname
    }
}


foreach ($ComputerName in $ComputerNames) {
    Write-Host "Pinging $ComputerName..."

    # Ping the computer name
    if (Test-Connection -ComputerName $ComputerName -Count 1 -Quiet) {
        Write-Host "$ComputerName is online. Connecting..."

        try {
            $session = New-PSSession -ComputerName $ComputerName

            Invoke-Command -Session $session -ScriptBlock { gpupdate /force }

            Write-Host "Successfully updated group policies on $ComputerName" -ForegroundColor Green
        } catch {
            Write-Host "Failed to establish session with $ComputerName. Error: $_" -ForegroundColor Red
        } finally {
            if ($session -ne $null) {
                Remove-PSSession $session
            }
        }
    } else {
        Write-Host "$ComputerName is offline. Skipping..." -ForegroundColor Yellow
    }
}
 
