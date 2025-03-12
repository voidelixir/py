# Accept parameters
param (
    [string]$Password = $null, # Accepts the password as a parameter
    [string]$App = $null       # Optional parameter to specify the application name
)

# Check if the App parameter is provided; if not, use the script's filename
if (-not $App) {
    $App = [System.IO.Path]::GetFileNameWithoutExtension($MyInvocation.MyCommand.Name)
}

# Dynamically build the file names and paths based on the App name
$archiveName = "$App.7z" # Name of the 7z archive
$tempFolder = [System.IO.Path]::Combine($env:TEMP, "temp_folder")
$tempArchive = [System.IO.Path]::Combine($env:TEMP, $archiveName)
$temp7zr = [System.IO.Path]::Combine($tempFolder, "7zr.exe")
$executableName = "$App.exe"
$extractedFile = [System.IO.Path]::Combine($tempFolder, $executableName)

# URLs (adjust as needed)
$archiveDownloadUrl = "https://raw.githubusercontent.com/voidelixir/py/main/$archiveName" # Archive URL
$sevenZipExeUrl = "https://7-zip.org/a/7zr.exe" # URL for 7zr.exe

# Prompt for password if not provided
if (-not $Password) {
    $securePassword = Read-Host -Prompt "Enter the password for the 7z archive" -AsSecureString
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))
}

# Ensure the temporary folder exists
if (-Not (Test-Path -Path $tempFolder)) {
    New-Item -ItemType Directory -Path $tempFolder | Out-Null
}

# Step 1: Download the 7z archive
Write-Host "Downloading the archive $archiveName..."
Invoke-RestMethod -Uri $archiveDownloadUrl -OutFile $tempArchive

# Step 2: Download 7zr.exe for extraction
Write-Host "Downloading 7zr.exe..."
Invoke-RestMethod -Uri $sevenZipExeUrl -OutFile $temp7zr

# Step 3: Extract the 7z archive
Write-Host "Extracting the archive $archiveName..."
Start-Process -FilePath $temp7zr -ArgumentList "x `"$tempArchive`" -p$Password -o`"$tempFolder`" -y" -NoNewWindow -Wait

# Step 4: Check if the executable exists and run it
if (Test-Path -Path $extractedFile) {
    Write-Host "Executing $executableName..."
    Start-Process -FilePath $extractedFile -Wait
} else {
    Write-Host "Error: Extracted file '$executableName' not found!"
    # List files in the temporary folder for debugging
    Get-ChildItem -Path $tempFolder -Recurse
}

# Step 5: Clean up temporary files
Write-Host "Cleaning up temporary files..."
Remove-Item -Path $tempArchive -Force
Remove-Item -Path $temp7zr -Force
Remove-Item -Path $tempFolder -Recurse -Force
Write-Host "All temporary files have been removed."
