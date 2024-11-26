# Import the CSV containing computer names
$computers = Import-Csv -Path "C:\computers.csv" # Update with the correct path to your CSV

# Define source path from network share and new local destination path on your PC
$sourcePath = "VOPATH"
$newLocalTempPath = "C:\Intel_Temp"

# Step 3: Process each computer in the CSV
foreach ($computer in $computers) {
    $computerName = $computer.ComputerName

    # Ping the computer to verify it is reachable
    if (Test-Connection -ComputerName $computerName -Count 1 -Quiet) {
        Write-Host "Computer $computerName is online. Proceeding..." -ForegroundColor Green

        # Define the remote destination path on the target computer
        $remoteDestinationPath = "C:\Intel"
        $directory = "C:\Program Files (x86)\CSI"
        $subDirectory = "C:\Program Files (x86)\CSI\Virtual Observer"
        $user = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name

        # Step 4: Create remote session and ensure required directories
        try {
            # Start remote session
            $session = New-PSSession -ComputerName $computerName

            # Ensure the "C:\Program Files (x86)\CSI" directory exists
            Invoke-Command -Session $session -ScriptBlock {
                param ($directory, $subDirectory)

                # Create the main directory if it doesn't exist
                if (-not (Test-Path -Path $directory)) {
                    New-Item -Path $directory -ItemType Directory -Force
                    Write-Host "Created directory: $directory" -ForegroundColor Green
                } else {
                    Write-Host "Directory already exists: $directory" -ForegroundColor Yellow
                }
            } -ArgumentList $directory, $subDirectory
        } catch {
            Write-Host ("Failed to create or verify the directory $directory on " + $computerName + ". Error: " + $_) -ForegroundColor Red
            continue
        }

        # Step 5: Copy the local directory to the remote machine using PowerShell Remoting
        try {
            # Verify if remote destination directory exists, if not create it as a directory
            Invoke-Command -Session $session -ScriptBlock {
                param ($remoteDestinationPath)
                if (-not (Test-Path -Path $remoteDestinationPath)) {
                    New-Item -Path $remoteDestinationPath -ItemType Directory -Force
                } elseif ((Get-Item $remoteDestinationPath).PSIsContainer -eq $false) {
                    Remove-Item -Path $remoteDestinationPath -Force
                    New-Item -Path $remoteDestinationPath -ItemType Directory -Force
                }
            } -ArgumentList $remoteDestinationPath

            # Copy files using the session
            Write-Host ("Copying files from " + $newLocalTempPath + " to " + $computerName + ":" + $remoteDestinationPath) -ForegroundColor Cyan
            Copy-Item -Path "$newLocalTempPath\*" -Destination $remoteDestinationPath -ToSession $session -Recurse -Force -ErrorAction Stop
            Write-Host ("Successfully copied " + $newLocalTempPath + " to " + $computerName + " at " + $remoteDestinationPath) -ForegroundColor Green
        } catch {
            Write-Host ("Failed to copy files to " + $computerName + ". Error: " + $_) -ForegroundColor Red
            continue
        }

        # Step 6: Kill services and processes, delete the contents of CSI directory
        try {
            Invoke-Command -Session $session -ScriptBlock {
                param ($directory, $subDirectory, $user)

                # Stop and delete services matching VO pattern
                Get-Service | Where-Object { $_.DisplayName -like '*VO*' -or $_.Name -like '*VO*' } | ForEach-Object {
                    if ($_.Status -eq 'Running') {
                        Stop-Service -Name $_.Name -Force
                    }
                }

                Get-Service | Where-Object { $_.DisplayName -like '*VO*' -or $_.Name -like '*VO*' } | ForEach-Object {
                    sc.exe delete $_.Name
                }

                # Stop processes matching 'VOA'
                Get-Process | Where-Object { $_.Name -like '*VOA*' } | ForEach-Object {
                    try {
                        Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue
                        Write-Host "Stopped process: $($_.Name) (ID: $($_.Id))" -ForegroundColor Green
                    } catch {
                        Write-Host "Failed to stop process: $($_.Name) (ID: $($_.Id))" -ForegroundColor Yellow
                    }
                }

                # Delete all contents in CSI directory but keep the directory intact
                if (Test-Path -Path $directory) {
                    Get-ChildItem -Path $directory -Recurse -Force | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
                    Write-Host "Removed all contents from: $directory" -ForegroundColor Green
                } else {
                    Write-Host "Directory not found: $directory" -ForegroundColor Yellow
                }

                # Ensure "Virtual Observer" subdirectory is re-created
                if (-not (Test-Path -Path $subDirectory)) {
                    New-Item -Path $subDirectory -ItemType Directory -Force
                    Write-Host "Recreated subdirectory: $subDirectory" -ForegroundColor Green
                }
            } -ArgumentList $directory, $subDirectory, $user -ErrorAction Stop
        } catch {
            Write-Host ("Failed to execute the cleanup on " + $computerName + ". Error: " + $_) -ForegroundColor Red
            continue
        }
    }
}
