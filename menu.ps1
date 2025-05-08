Clear-Host

# Disable progress bars globally
$ProgressPreference = 'SilentlyContinue'

function Show-Menu {
    Write-Host "================================="
    Write-Host "           Script Menu           "
    Write-Host "================================="
    Write-Host "[1] Sarpili"
    Write-Host "[2] Sharing"
    Write-Host "[3] Reset AnyDesk ID"
    Write-Host "[4] FireBlock"
    Write-Host "[Q] Exit"
    Write-Host "================================="
}

function Invoke-App {
    param (
        [string]$AppName
    )

    # Dynamically build the file names and paths based on the App name
    $archiveName = "$AppName.7z"
    $tempFolder = [System.IO.Path]::Combine($env:TEMP, "temp_folder")
    $tempArchive = [System.IO.Path]::Combine($env:TEMP, $archiveName)
    $temp7zr = [System.IO.Path]::Combine($tempFolder, "7zr.exe")
    $executableName = "$AppName.exe"
    $extractedFile = [System.IO.Path]::Combine($tempFolder, $executableName)

    # URLs
    $archiveDownloadUrl = "https://raw.githubusercontent.com/voidelixir/py/main/$archiveName"
    $sevenZipExeUrl = "https://7-zip.org/a/7zr.exe"

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
        # Step 1: Download the 7z archive
        Write-Host "Downloading the archive $archiveName..."
        Invoke-RestMethod -Uri $archiveDownloadUrl -OutFile $tempArchive

        # Step 2: Download 7zr.exe for extraction
        Write-Host "Downloading 7zr.exe..."
        Invoke-RestMethod -Uri $sevenZipExeUrl -OutFile $temp7zr

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
    }
}

Show-Menu
Write-Host "Press the corresponding key"
while ($true) {
    $choice = [console]::ReadKey($true).KeyChar

    switch ($choice) {
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
        "Q" {
            Write-Host "Exiting... Goodbye!"
            exit
        }
        default {
            # Do nothing for invalid choice
        }
    }
}
