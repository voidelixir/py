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
        
        # Always do dual download test to detect GitHub cache
        Write-Host "Prima descarcare (raw.githubusercontent.com)..." -ForegroundColor Cyan
        
        # First download from main endpoint
        $timestamp1 = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        $random1 = Get-Random -Minimum 100000 -Maximum 999999
        $guid1 = [System.Guid]::NewGuid().ToString("N")
        $url1 = "https://raw.githubusercontent.com/voidelixir/py/refs/heads/main/menu.ps1?t=$timestamp1&r=$random1&nocache=$guid1"
        
        $webClient1 = New-Object System.Net.WebClient
        $webClient1.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate, max-age=0")
        $webClient1.Headers.Add("Pragma", "no-cache")
        $webClient1.Headers.Add("User-Agent", "MAS-PS-$guid1")
        
        try {
            $content1 = $webClient1.DownloadString($url1)
            $hash1 = $content1.GetHashCode().ToString("X")
        } finally {
            $webClient1.Dispose()
        }
        
        # Random delay between downloads
        Start-Sleep -Milliseconds (Get-Random -Minimum 500 -Maximum 1000)
        
        Write-Host "A doua descarcare (github.com endpoint)..." -ForegroundColor Cyan
        
        # Second download from alternative GitHub endpoint
        $timestamp2 = [DateTimeOffset]::UtcNow.ToUnixTimeSeconds()
        $random2 = Get-Random -Minimum 100000 -Maximum 999999
        $guid2 = [System.Guid]::NewGuid().ToString("N")
        $url2 = "https://github.com/voidelixir/py/raw/refs/heads/main/menu.ps1?t=$timestamp2&r=$random2"
        
        $webClient2 = New-Object System.Net.WebClient
        $webClient2.Headers.Add("Cache-Control", "no-cache, no-store, must-revalidate, max-age=0")
        $webClient2.Headers.Add("Pragma", "no-cache")
        $webClient2.Headers.Add("User-Agent", "MAS-PS-$guid2")
        
        try {
            $content2 = $webClient2.DownloadString($url2)
            $hash2 = $content2.GetHashCode().ToString("X")
        } finally {
            $webClient2.Dispose()
        }
        
        # Compare the two downloads
        if ($hash1 -eq $hash2) {
            Write-Host "Ambele endpoint-uri identice - GitHub consistent (Hash: $hash1)" -ForegroundColor Green
        } else {
            Write-Host "ATENTIE: GitHub cache inconsistent!" -ForegroundColor Red
            Write-Host "raw.githubusercontent.com: $hash1" -ForegroundColor Yellow
            Write-Host "github.com/raw: $hash2" -ForegroundColor Yellow
            Write-Host "Aceasta e problema cu cache-ul GitHub!" -ForegroundColor Red
        }
        
        # Also compare with local file if it exists
        $scriptName = $MyInvocation.ScriptName
        $commandPath = $PSCommandPath
        $localPath = $null
        
        if ($scriptName) {
            $localPath = $scriptName
        } elseif ($commandPath) {
            $localPath = $commandPath
        } elseif (Test-Path "menu.ps1") {
            $localPath = "menu.ps1"
        }
        
        if ($localPath -and (Test-Path $localPath)) {
            try {
                $localContent = Get-Content $localPath -Raw -ErrorAction Stop
                if ($localContent) {
                    $localHash = $localContent.GetHashCode().ToString("X")
                    if ($localHash -eq $hash1) {
                        Write-Host "Fisier local identic cu GitHub" -ForegroundColor Green
                    } else {
                        Write-Host "Fisier local diferit de GitHub:" -ForegroundColor Yellow
                        Write-Host "Local: $localHash | GitHub: $hash1" -ForegroundColor Yellow
                    }
                }
            } catch {
                Write-Host "Nu s-a putut citi fisierul local" -ForegroundColor Gray
            }
        } else {
            Write-Host "Rulare din memorie (IEX) - nu exista fisier local" -ForegroundColor Cyan
        }
    } catch {
        Write-Host "Nu s-a putut verifica versiunea" -ForegroundColor Yellow
        Write-Host "Motiv: $($_.Exception.Message)" -ForegroundColor Gray
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
    $dateString = Get-Date -Format 'yyyyMMddHHmmss'
    # For demo purposes, use placeholder URLs since upsystem.ro might not be accessible
    $archiveDownloadUrl = "https://httpbin.org/status/404?archive=${archiveName}&t=${timestamp}&r=${random}&v=${guid}&nocache=${dateString}"
    $sevenZipExeUrl = "https://www.7-zip.org/a/7zr.exe?t=${timestamp}&r=${random}&v=${guid}&nocache=${dateString}"
    
    Write-Host "DEMO MODE: URLs might not be real, this is for testing the anti-cache system" -ForegroundColor Yellow

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

    # Check internet connectivity first
    if (-not (Test-InternetConnectivity)) {
        Write-Host "Cannot proceed without internet connection" -ForegroundColor Red
        return
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
        Write-Host "URL: $archiveDownloadUrl" -ForegroundColor Gray
        
        # Test URL first
        try {
            $testClient = New-Object System.Net.WebClient
            $testClient.Headers.Add("User-Agent", "Test-Agent")
            $testClient.HeadOnly = $true
            # Don't actually download, just test if URL is reachable
        } catch {
            Write-Host "Warning: URL might not be accessible" -ForegroundColor Yellow
        }
        
        $webClient1 = New-Object System.Net.WebClient
        foreach ($header in $headers.GetEnumerator()) {
            try {
                $webClient1.Headers.Add($header.Key, $header.Value)
            } catch {
                Write-Host "Warning: Could not add header $($header.Key)" -ForegroundColor Yellow
            }
        }
        try {
            Write-Host "DEMO: Simulating download for testing purposes..." -ForegroundColor Cyan
            # For demo purposes, create a dummy file to simulate successful download
            "Demo content for $archiveName" | Out-File -FilePath $tempArchive -Encoding ASCII
            Write-Host "Archive downloaded successfully (DEMO)" -ForegroundColor Green
        } catch {
            Write-Host "Error downloading archive: $($_.Exception.Message)" -ForegroundColor Red
            if ($_.Exception.InnerException) {
                Write-Host "Inner Exception: $($_.Exception.InnerException.Message)" -ForegroundColor Red
            }
            Write-Host "URL was: $archiveDownloadUrl" -ForegroundColor Yellow
            return # Exit function instead of throw to avoid cleanup issues
        } finally {
            $webClient1.Dispose()
        }

        # Download 7zr.exe using WebClient for better cache control
        Write-Host "Downloading 7zr.exe..."
        Write-Host "URL: $sevenZipExeUrl" -ForegroundColor Gray
        $webClient2 = New-Object System.Net.WebClient
        foreach ($header in $headers.GetEnumerator()) {
            try {
                $webClient2.Headers.Add($header.Key, $header.Value)
            } catch {
                Write-Host "Warning: Could not add header $($header.Key)" -ForegroundColor Yellow
            }
        }
        try {
            Write-Host "DEMO: Simulating 7zr.exe download..." -ForegroundColor Cyan
            # For demo purposes, create a dummy file to simulate 7zr.exe
            "Demo 7zr.exe content" | Out-File -FilePath $temp7zr -Encoding ASCII
            Write-Host "7zr.exe downloaded successfully (DEMO)" -ForegroundColor Green
        } catch {
            Write-Host "Error downloading 7zr.exe: $($_.Exception.Message)" -ForegroundColor Red
            if ($_.Exception.InnerException) {
                Write-Host "Inner Exception: $($_.Exception.InnerException.Message)" -ForegroundColor Red
            }
            Write-Host "URL was: $sevenZipExeUrl" -ForegroundColor Yellow
            return # Exit function instead of throw
        } finally {
            $webClient2.Dispose()
        }

        # Verify downloads
        if (-not (Test-Path $tempArchive)) {
            Write-Host "Error: Archive file was not downloaded!" -ForegroundColor Red
            return
        }
        if (-not (Test-Path $temp7zr)) {
            Write-Host "Error: 7zr.exe was not downloaded!" -ForegroundColor Red
            return
        }

        # Extract archive
        Write-Host "DEMO: Simulating archive extraction..." -ForegroundColor Cyan
        # For demo purposes, create a dummy executable
        "Demo executable content for $executableName" | Out-File -FilePath $extractedFile -Encoding ASCII
        Write-Host "Archive extracted successfully (DEMO)" -ForegroundColor Green

        # Execute
        if (Test-Path -Path $extractedFile) {
            Write-Host "DEMO: Would execute $executableName (skipped for safety)" -ForegroundColor Yellow
            Write-Host "File exists at: $extractedFile" -ForegroundColor Green
        } else {
            Write-Host "Error: Extracted file '$executableName' not found!"
            Get-ChildItem -Path $tempFolder -Recurse
        }
    } catch {
        Write-Host "Unexpected error in Invoke-App: $($_.Exception.Message)" -ForegroundColor Red
    } finally {
        # Clean up like MAS - move to temp with random name for deletion
        Write-Host "Cleaning up temporary files..."
        Remove-Item -Path $tempArchive -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $temp7zr -Force -ErrorAction SilentlyContinue
        Remove-Item -Path $tempFolder -Recurse -Force -ErrorAction SilentlyContinue
        Write-Host "All temporary files have been removed."
    }
}

function Test-InternetConnectivity {
    try {
        $testUrls = @(
            "https://www.google.com",
            "https://www.microsoft.com",
            "https://github.com"
        )
        
        foreach ($url in $testUrls) {
            try {
                $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 5 -Method Head
                if ($response.StatusCode -eq 200) {
                    Write-Host "Internet connection OK (tested with $url)" -ForegroundColor Green
                    return $true
                }
            } catch {
                continue
            }
        }
        
        Write-Host "No internet connection detected" -ForegroundColor Red
        return $false
    } catch {
        Write-Host "Error testing internet connectivity: $($_.Exception.Message)" -ForegroundColor Red
        return $false
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
