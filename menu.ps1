Clear-Host

# Aggressive cache purge and PowerShell optimization - must be early in script
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers(); [System.GC]::Collect()

# Disable PowerShell caching and optimizations
$PSDefaultParameterValues.Clear()
$ExecutionContext.InvokeCommand.CommandNotFoundAction = 'Continue'
[System.Runtime.GCSettings]::LatencyMode = [System.Runtime.GCLatencyMode]::Interactive

# Clear PowerShell module cache
Get-Module | Remove-Module -Force -ErrorAction SilentlyContinue

# Disable progress bars globally
$ProgressPreference = 'SilentlyContinue'

# Force disable web client caching
[System.Net.ServicePointManager]::DefaultConnectionLimit = 999
[System.Net.ServicePointManager]::Expect100Continue = $false
[System.Net.ServicePointManager]::UseNagleAlgorithm = $false
[System.Net.ServicePointManager]::CheckCertificateRevocationList = $false

# Clear DNS cache if possible
try { Clear-DnsClientCache -ErrorAction SilentlyContinue } catch { }

# Force fresh execution context
$env:PSModulePath = $env:PSModulePath
$PSVersionTable.Clear() 2>$null
Remove-Variable * -ErrorAction SilentlyContinue -Exclude PWD,*Preference,PSVersionTable,ExecutionContext

# Generate cache-busting parameter
$CacheBuster = [System.Guid]::NewGuid().ToString("N")

# Function to create no-cache headers
function Get-NoCacheHeaders {
    return @{
        'Cache-Control' = 'no-cache, no-store, must-revalidate'
        'Pragma' = 'no-cache'
        'Expires' = '0'
        'User-Agent' = "PowerShell-CacheBuster-$CacheBuster"
    }
}

function Show-Menu {
    Write-Host "================================="
    Write-Host "           Script Menu           "
    Write-Host "================================="
    Write-Host "[0] AIOTVA"	
    Write-Host "[1] Sarpili"
    Write-Host "[2] Sharing"
    Write-Host "[3] Reset AnyDesk ID"
    Write-Host "[4] FireBlock"
    Write-Host "[5] OEM Driver Uninstaller"
    Write-Host "[Q] Exit"
    Write-Host "================================="
}

function Invoke-App {
    param (
        [string]$AppName
    )

    # Regenerate cache-busting parameters for each invocation
    $freshCacheBuster = [System.Guid]::NewGuid().ToString("N")
    $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $random = Get-Random -Minimum 10000 -Maximum 99999
    
    # Aggressive cache clearing for each invocation
    [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers(); [System.GC]::Collect()
    [System.Runtime.GCSettings]::LatencyMode = [System.Runtime.GCLatencyMode]::Interactive
    
    # Clear PowerShell command cache
    $ExecutionContext.InvokeCommand.ClearCache()
    
    # Force new random temp folder to avoid file caching
    $randomId = [System.Guid]::NewGuid().ToString("N").Substring(0,8)
    $tempFolder = [System.IO.Path]::Combine($env:TEMP, "temp_folder_$randomId")
    
    # Clear DNS cache for fresh lookups
    try { Clear-DnsClientCache -ErrorAction SilentlyContinue } catch { }

    # Dynamically build the file names and paths based on the App name
    $archiveName = "$AppName.7z"
    $tempArchive = [System.IO.Path]::Combine($env:TEMP, "$archiveName" + "_$randomId")
    $temp7zr = [System.IO.Path]::Combine($tempFolder, "7zr_$randomId.exe")
    $executableName = "$AppName.exe"
    $extractedFile = [System.IO.Path]::Combine($tempFolder, $executableName)

    # URLs with cache-busting parameters
#   $archiveDownloadUrl = "https://raw.githubusercontent.com/voidelixir/py/main/$archiveName?t=$timestamp&r=$random&cb=$freshCacheBuster"
    $archiveDownloadUrl = "https://upsystem.ro/github/$archiveName?t=$timestamp&r=$random&cb=$freshCacheBuster"
    $sevenZipExeUrl = "https://7-zip.org/a/7zr.exe?t=$timestamp&r=$random&cb=$freshCacheBuster"

    # Prompt for a secure password
    $SecurePassword = Read-Host "Enter the password for the 7z archive" -AsSecureString

    # Ensure the temporary folder exists
    if (-Not (Test-Path -Path $tempFolder)) {
        New-Item -ItemType Directory -Path $tempFolder | Out-Null
    }

    if ($AppName -eq 'sarpili') {
        # Check if Chocolatey is installed
        if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
            Write-Host "Chocolatey is not installed. Installing Chocolatey..."

            # Install Chocolatey
            Set-ExecutionPolicy Bypass -Scope Process -Force
            Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

            # Update environment variables
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

            # Recheck if Chocolatey is installed
            if (-Not (Get-Command choco -ErrorAction SilentlyContinue)) {
                Write-Host "Error: Chocolatey installation failed. Exiting."
                return
            }

            Write-Host "Chocolatey installed successfully."
        }

        Write-Host "Launching Sarpili..."
    }

    try {
        # Get no-cache headers
        $headers = Get-NoCacheHeaders
        
        # Step 1: Download the 7z archive
        Write-Host "Downloading the archive $archiveName..."
        Invoke-RestMethod -Uri $archiveDownloadUrl -OutFile $tempArchive -Headers $headers

        # Step 2: Download 7zr.exe for extraction
        Write-Host "Downloading 7zr.exe..."
        Invoke-RestMethod -Uri $sevenZipExeUrl -OutFile $temp7zr -Headers $headers

        # Step 3: Extract the 7z archive
        Write-Host "Extracting the archive $archiveName..."
        Start-Process -FilePath $temp7zr -ArgumentList "x `"$tempArchive`" -p$([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword))) -o`"$tempFolder`" -y" -NoNewWindow -Wait

        # Step 4: Check if the executable exists and run it
        if (Test-Path -Path $extractedFile) {
            Write-Host "Executing $executableName..."
            Start-Process -FilePath $extractedFile -Wait
        } else {
            Write-Host "Error: Extracted file '$executableName' not found!"
            Get-ChildItem -Path $tempFolder -Recurse
        }
    } finally {
        # Step 5: Clean up temporary files
        Write-Host "Cleaning up temporary files..."
        Remove-Item -Path $tempArchive -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $temp7zr -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "All temporary files have been removed."
        
        # Aggressive cache clearing after execution
        [System.GC]::Collect(); [System.GC]::WaitForPendingFinalizers(); [System.GC]::Collect()
        try { Clear-DnsClientCache -ErrorAction SilentlyContinue } catch { }
        $ExecutionContext.InvokeCommand.ClearCache()
    }
}

Show-Menu
Write-Host "Press the corresponding key"
while ($true) {
    $choice = [console]::ReadKey($true).KeyChar

    switch ($choice) {
        "0" {
            Write-Host "Running AIOTVA..."
            Invoke-App -AppName 'aiotva'
            Show-Menu
        }
        "1" {
            Write-Host "Running Sarpili..."
            Invoke-App -AppName 'sarpili'
            Show-Menu
        }
        "2" {
            Write-Host "Running Sharing..."
            Invoke-App -AppName 'sharing'
            Show-Menu
        }
        "3" {
            Write-Host "Resetting AnyDesk ID..."
            Invoke-App -AppName 'resetad'
            Show-Menu
        }
        "4" {
            Write-Host "Running FireBlock..."
            Invoke-App -AppName 'fireblock'
            Show-Menu
        }
        "5" {
            Write-Host "Running ODU..."
            Invoke-App -AppName 'odu'
            Show-Menu
        }
        "Q" {
            Write-Host "Exiting... Goodbye!"
            exit
        }
        default {
            # Do nothing for invalid choice
        }
    }
}
