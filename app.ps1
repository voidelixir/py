# Add a parameter for the application
param (
    [string]$App = $null # Optional parameter to specify the application
)

# Check if the parameter is provided; if not, use the script's name
if ($null -eq $App) {
    $App = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
}

# Build the archive and executable names dynamically
$archiveName = "$App.7z"
$tempFolder = [System.IO.Path]::Combine($env:TEMP, "temp_folder")
$tempArchive = [System.IO.Path]::Combine($env:TEMP, $archiveName)
$temp7zr = [System.IO.Path]::Combine($tempFolder, "7zr.exe")
$executableName = "$App.exe"
$extractedFile = [System.IO.Path]::Combine($tempFolder, $executableName)

# URLs for downloading
$archiveDownloadUrl = "https://raw.githubusercontent.com/voidelixir/py/main/$archiveName"
$sevenZipExeUrl = "https://7-zip.org/a/7zr.exe"

# Prompt for password if not provided
if (-not $Password) {
    $securePassword = Read-Host -Prompt "Enter the password for the 7z archive" -AsSecureString
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))
}

# Ensure the temporary folder exists
if (-Not (Test-Path -Path $tempFolder)) {
    New-Item -ItemType Directory -Path $tempFolder | Out-Null
}

# Download the archive
Write-Host "Downloading the archive $archiveName..."
Invoke-RestMethod -Uri $archiveDownloadUrl -OutFile $tempArchive

# Download 7zr.exe
Write-Host "Downloading 7zr.exe..."
Invoke-RestMethod -Uri $sevenZipExeUrl -OutFile $temp7zr

# Extract the archive
Write-Host "Extracting the archive $archiveName..."
Start-Process -FilePath $temp7zr -ArgumentList "x `"$tempArchive`" -p$Password -o`"$tempFolder`" -y" -NoNewWindow -Wait

# Check if the executable exists and run it
if (Test-Path -Path $extractedFile) {
    Write-Host "Executing $executableName..."
    Start-Process -FilePath $extractedFile -Wait
} else {
    Write-Host "Error: Extracted file '$executableName' not found!" -ForegroundColor Red
    Get-ChildItem -Path $tempFolder -Recurse
}

# Clean up temporary files
Write-Host "Cleaning up temporary files..."
Remove-Item -Path $tempArchive -Force
Remove-Item -Path $temp7zr -Force
Remove-Item -Path $tempFolder -Recurse -Force
Write-Host "All temporary files have been removed."