# Random header to avoid caching - MAS strategy
# $([System.Guid]::NewGuid().ToString("N"))

Clear-Host

# MAS-inspired aggressive cache prevention
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
[System.Net.ServicePointManager]::CheckCertificateRevocationList = $false
[System.Net.ServicePointManager]::MaxServicePointIdleTime = 0
[System.Net.ServicePointManager]::DefaultConnectionLimit = 20
[System.Net.ServicePointManager]::EnableDnsRoundRobin = $true
[System.Net.ServicePointManager]::UseNagleAlgorithm = $false

# Force aggressive connection cleanup at startup
try {
    # Clear all existing service points like MAS strategy
    $commonUris = @(
        "https://raw.githubusercontent.com",
        "https://github.com", 
        "https://upsystem.ro",
        "https://7-zip.org"
    )
    
    foreach ($uri in $commonUris) {
        try {
            [System.Net.ServicePointManager]::FindServicePoint([System.Uri]$uri).CloseConnectionGroup("")
        } catch {
            # Ignore individual cleanup errors
        }
    }
    
    # Alternative DNS flush using cmd instead of direct ipconfig
    try {
        cmd /c "ipconfig /flushdns" *>$null
    } catch {
        # Ignore DNS flush errors
    }
} catch {
    # Ignore cleanup errors
}

# Disable progress bars
$ProgressPreference = 'SilentlyContinue'

# Check version against GitHub with enhanced error handling
function Test-ScriptVersion {
    try {
        Write-Host "Verificare versiune..." -ForegroundColor Cyan
        
        # Force DNS flush and ServicePoint cleanup like MAS
        try {
            [System.Net.ServicePointManager]::FindServicePoint([System.Uri]"https://raw.githubusercontent.com").CloseConnectionGroup("")
        } catch {
            # Ignore cleanup errors
        }
        
        # Get local script content and calculate simple hash
        $scriptPath = $MyInvocation.ScriptName
        if (-not $scriptPath) {
            $scriptPath = $PSCommandPath
        }
        
        if (-not $scriptPath -or -not (Test-Path $scriptPath)) {
            Write-Host "Nu s-a putut determina calea scriptului" -ForegroundColor Yellow
            return
        }
        
        $localContent = Get-Content $scriptPath -Raw -ErrorAction Stop
        $localHash = $localContent.GetHashCode().ToString("X")
        
        # Random delay to avoid timing cache hits
        Start-Sleep -Milliseconds (Get-Random -Minimum 100 -Maximum 500)
        
        Write-Host "Conectare la GitHub..." -ForegroundColor Cyan
        
        # Force new connection with timestamp and multiple cache busters
        $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        $random = Get-Random -Minimum 100000 -Maximum 999999
        $guid = [System.Guid]::NewGuid().ToString("N")
        $url = "https://raw.githubusercontent.com/voidelixir/py/refs/heads/main/menu.ps1?t=$timestamp&r=$random&nocache=$guid&v=$(Get-Date -Format 'yyyyMMddHHmmss')"
        
        # Use WebClient for more aggressive cache bypass like MAS
        $webClient = New-Object System.Net.WebClient
        $webClient.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate, max-age=0")
        $webClient.Headers.Add("Pragma", "no-cache")
        $webClient.Headers.Add("Expires", "Thu, 01 Jan 1970 00:00:00 GMT")
        $webClient.Headers.Add("User-Agent", "MAS-PS-$guid")
        $webClient.Headers.Add("X-Requested-With", "XMLHttpRequest")
        
        try {
            $githubContent = $webClient.DownloadString($url)
            $githubHash = $githubContent.GetHashCode().ToString("X")
            
            # Compare versions
            if ($localHash -eq $githubHash) {
                Write-Host "Versiune fresh (Hash: $localHash)" -ForegroundColor Green
            } else {
                Write-Host "ATENTIE: Posibil cache detectat!" -ForegroundColor Red
                Write-Host "Local: $localHash | GitHub: $githubHash" -ForegroundColor Yellow
            }
        } finally {
            $webClient.Dispose()
        }
    } catch {
        Write-Host "Nu s-a putut verifica versiunea" -ForegroundColor Yellow
        Write-Host "Motiv: $($_.Exception.Message)" -ForegroundColor Gray
        try {
            if ($localContent) {
                Write-Host "Hash local: $($localContent.GetHashCode().ToString('X'))" -ForegroundColor Gray
            }
        } catch {
            Write-Host "Nu s-a putut calcula hash local" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# Check version before showing menu
Test-ScriptVersion

# Simple no-cache headers with MAS-style aggressive cache busting
function Get-NoCacheHeaders {
    $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $random = Get-Random -Minimum 100000 -Maximum 999999
    $guid = [System.Guid]::NewGuid().ToString("N")
    
    return @{
        'Cache-Control' = 'no-cache, no-store, must-revalidate, proxy-revalidate, max-age=0'
        'Pragma' = 'no-cache'
        'Expires' = 'Thu, 01 Jan 1970 00:00:00 GMT'
        'If-Modified-Since' = 'Mon, 26 Jul 1997 05:00:00 GMT'
        'User-Agent' = "MAS-PowerShell-$guid"
        'X-Requested-With' = 'XMLHttpRequest'
        'X-Cache-Buster' = "$timestamp-$random-$guid"
        'Connection' = 'close'
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

    # MAS-style random generation with enhanced randomness
    $timestamp = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
    $random = Get-Random -Minimum 100000 -Maximum 999999
    $guid = [System.Guid]::NewGuid().ToString("N")
    
    # MAS-style random temp folder using GetRandomFileName approach
    $randomFileName = [System.IO.Path]::GetRandomFileName().Replace('.', '')
    $tempFolder = [System.IO.Path]::Combine($env:TEMP, "temp_$randomFileName")
    
    # Dynamic file naming with random elements like MAS
    $archiveName = "$AppName.7z"
    $tempArchive = [System.IO.Path]::Combine($env:TEMP, "$archiveName" + "_$random")
    $temp7zr = [System.IO.Path]::Combine($tempFolder, "7zr_$randomFileName.exe")
    $executableName = "$AppName.exe"
    $extractedFile = [System.IO.Path]::Combine($tempFolder, $executableName)

    # URLs with aggressive cache-busting like MAS
    $archiveDownloadUrl = "https://upsystem.ro/github/$archiveName?t=$timestamp&r=$random&v=$guid&nocache=$(Get-Date -Format 'yyyyMMddHHmmss')"
    $sevenZipExeUrl = "https://7-zip.org/a/7zr.exe?t=$timestamp&r=$random&v=$guid&nocache=$(Get-Date -Format 'yyyyMMddHHmmss')"

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
        # Get headers with aggressive cache busting
        $headers = Get-NoCacheHeaders
        
        # Force connection cleanup like MAS before downloading
        try {
            [System.Net.ServicePointManager]::FindServicePoint([System.Uri]$archiveDownloadUrl).CloseConnectionGroup("")
            [System.Net.ServicePointManager]::FindServicePoint([System.Uri]$sevenZipExeUrl).CloseConnectionGroup("")
        } catch {
            # Ignore cleanup errors
        }
        
        # Random delay to avoid cache timing
        Start-Sleep -Milliseconds (Get-Random -Minimum 50 -Maximum 200)
        
        # Download archive using WebClient for better cache control
        Write-Host "Downloading the archive $archiveName..."
        $webClient1 = New-Object System.Net.WebClient
        foreach ($header in $headers.GetEnumerator()) {
            $webClient1.Headers.Add($header.Key, $header.Value)
        }
        try {
            $webClient1.DownloadFile($archiveDownloadUrl, $tempArchive)
        } finally {
            $webClient1.Dispose()
        }

        # Download 7zr.exe using WebClient for better cache control
        Write-Host "Downloading 7zr.exe..."
        $webClient2 = New-Object System.Net.WebClient
        foreach ($header in $headers.GetEnumerator()) {
            $webClient2.Headers.Add($header.Key, $header.Value)
        }
        try {
            $webClient2.DownloadFile($sevenZipExeUrl, $temp7zr)
        } finally {
            $webClient2.Dispose()
        }

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
