Clear-Host
function Show-Menu {
    Write-Host "================================="
    Write-Host "           Script Menu           "
    Write-Host "================================="
    Write-Host "[1] Execute Sarpili Script"
    Write-Host "[2] Execute Sharing Script"
    Write-Host "[3] Reset AnyDesk ID"
    Write-Host "[4] Exit"
    Write-Host "================================="
}

Show-Menu
Write-Host "Press the corresponding key"
while ($true) {
    $choice = [console]::ReadKey($true).KeyChar

    switch ($choice) {
        "1" {
            Write-Host "Running Sarpili Script..."
            
            # Check if Chocolatey is installed
            if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
                Write-Host "Chocolatey is not installed. Installing Chocolatey..."
                
                # Install Chocolatey and update environment variables
                & ([Diagnostics.Process]::GetCurrentProcess().ProcessName) -NoP -c (
                    [String]::Join(' ', (
                        'Start-Process', [Diagnostics.Process]::GetCurrentProcess().ProcessName,
                        '-UseNewEnvironment -NoNewWindow -Wait -Args ''-c'',',
                        '''Get-ChildItem env: | &{process{ $_.Key + [char]9 + $_.Value }}'''
                    ))
                ) | &{process{
                    [Environment]::SetEnvironmentVariable(
                        $_.Split("`t")[0], # Key
                        $_.Split("`t")[1], # Value
                        'Process'          # Scope
                    )
                }}
                
                Set-ExecutionPolicy Bypass -Scope Process -Force
                [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
                iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

                # Verify Chocolatey installation
                if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
                    Write-Host "Failed to install Chocolatey. Exiting..."
                    exit
                }
                Write-Host "Chocolatey installed successfully."
            }

            # Run Sarpili Script
            powershell -command "& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/voidelixir/py/main/app.ps1))) -App 'sarpili'"
            Pause
            Show-Menu
        }
        "2" {
            Write-Host "Running Sharing Script..."
            powershell -command "& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/voidelixir/py/main/app.ps1))) -App 'sharing'"
            Pause
            Show-Menu
        }
        "3" {
            Write-Host "Resetting AnyDesk ID..."
            powershell -command "& ([ScriptBlock]::Create((irm https://raw.githubusercontent.com/voidelixir/py/main/app.ps1))) -App 'resetad'"
            Pause
            Show-Menu
        }
        "4" {
            Write-Host "Exiting... Goodbye!"
            exit
        }
        default {
            # Do nothing for invalid choice
        }
    }
}
