# Random header to avoid caching - MAS strategy
# $([System.Guid]::NewGuid().ToString("N"))

Clear-Host

# MAS-inspired cache prevention
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12

# Disable progress bars
$ProgressPreference = 'SilentlyContinue'

# Generate cache-busting parameter like MAS
$CacheBuster = [System.Guid]::NewGuid().ToString("N")

# Check version against GitHub
function Check-ScriptVersion {
    try {
        Write-Host "Verificare versiune..." -ForegroundColor Cyan
        
        # Get local script content and calculate simple hash
        $localContent = Get-Content $MyInvocation.MyCommand.Path -Raw
        $localHash = $localContent.GetHashCode().ToString("X")
        
        # Get GitHub content and calculate simple hash
        $headers = @{ 
            'Cache-Control' = 'no-cache'
            'User-Agent' = 'PowerShell-Script'
        }
        
        Write-Host "Conectare la GitHub..." -ForegroundColor Cyan
        $githubContent = Invoke-RestMethod "https://raw.githubusercontent.com/voidelixir/py/refs/heads/main/menu.ps1" -Headers $headers -TimeoutSec 10
        $githubHash = $githubContent.GetHashCode().ToString("X")
        
        # Compare versions
        if ($localHash -eq $githubHash) {
            Write-Host "Versiune fresh (Hash: $localHash)" -ForegroundColor Green
        } else {
            Write-Host "ATENTIE: Posibil cache detectat!" -ForegroundColor Red
            Write-Host "Local: $localHash | GitHub: $githubHash" -ForegroundColor Yellow
        }
    } catch {
        Write-Host "Nu s-a putut verifica versiunea" -ForegroundColor Yellow
        Write-Host "Motiv: $($_.Exception.Message)" -ForegroundColor Gray
        Write-Host "Hash local: $($localContent.GetHashCode().ToString('X'))" -ForegroundColor Gray
    }
    Write-Host ""
}

# Check version before showing menu
Check-ScriptVersion

# Simple no-cache headers
function Get-NoCacheHeaders {
    return @{
        'Cache-Control' = 'no-cache, no-store, must-revalidate'
        'Pragma' = 'no-cache'
        'User-Agent' = "MAS-PowerShell-$([System.Guid]::NewGuid().ToString("N"))"
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

    # MAS-style random generation
    $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $random = Get-Random -Minimum 100000 -Maximum 999999
    
    # MAS-style random temp folder using GetRandomFileName approach
    $randomFileName = [System.IO.Path]::GetRandomFileName().Replace('.', '')
    $tempFolder = [System.IO.Path]::Combine($env:TEMP, "temp_$randomFileName")
    
    # Dynamic file naming with random elements like MAS
    $archiveName = "$AppName.7z"
    $tempArchive = [System.IO.Path]::Combine($env:TEMP, "$archiveName" + "_$random")
    $temp7zr = [System.IO.Path]::Combine($tempFolder, "7zr_$randomFileName.exe")
    $executableName = "$AppName.exe"
    $extractedFile = [System.IO.Path]::Combine($tempFolder, $executableName)

    # URLs with cache-busting like MAS
    $archiveDownloadUrl = "https://upsystem.ro/github/$archiveName?t=$timestamp&r=$random"
    $sevenZipExeUrl = "https://7-zip.org/a/7zr.exe?t=$timestamp&r=$random"

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
        # Get headers
        $headers = Get-NoCacheHeaders
        
        # Download archive
        Write-Host "Downloading the archive $archiveName..."
        Invoke-RestMethod -Uri $archiveDownloadUrl -OutFile $tempArchive -Headers $headers

        # Download 7zr.exe
        Write-Host "Downloading 7zr.exe..."
        Invoke-RestMethod -Uri $sevenZipExeUrl -OutFile $temp7zr -Headers $headers

        # Extract archive
        Write-Host "Extracting the archive $archiveName..."
        Start-Process -FilePath $temp7zr -ArgumentList "x `"$tempArchive`" -p$([Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecurePassword))) -o`"$tempFolder`" -y" -NoNewWindow -Wait

        # Execute
        if (Test-Path -Path $extractedFile) {
            Write-Host "Executing $executableName..."
            Start-Process -FilePath $extractedFile -Wait
        } else {
            Write-Host "Error: Extracted file '$executableName' not found!"
            Get-ChildItem -Path $tempFolder -Recurse
        }
    } finally {
        # Clean up like MAS - move to temp with random name for deletion
        Write-Host "Cleaning up temporary files..."
        Remove-Item -Path $tempArchive -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $temp7zr -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "All temporary files have been removed."
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
