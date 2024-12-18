# Variables
$targetDirectory = "C:\inetpub\wwwroot"
$mountDrive = "L:"  # The drive letter where the file share is mounted

# Enable SMB2 protocol before performing any operations
Set-SmbServerConfiguration -EnableSMB2Protocol $true

# Mount the Azure File Share
$connectTestResult = Test-NetConnection -ComputerName "shdr.file.core.windows.net" -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Save the password so the drive will persist on reboot (ensure cmdkey command is valid)
    cmd.exe /C "cmdkey /add:`"shdr.file.core.windows.net`" /user:`"shdr\shdr`" /pass:$env:accessKey"

    # Mount the drive
    New-PSDrive -Name L -PSProvider FileSystem -Root "\\shdr.file.core.windows.net\webappfiles" -Persist
} else {
    Write-Error "Unable to reach the Azure storage account via port 445. Ensure your network allows access to port 445."
    exit
}

# Wait for a few seconds to ensure the mounted drive is ready
Start-Sleep -Seconds 10

# Ensure the target directory ("Fileshare data") exists
if (-not (Test-Path -Path $targetDirectory)) {
    New-Item -ItemType Directory -Path $targetDirectory
}

# Copy files from the mounted Azure File Share to the target directory
try {
    # סרוק את כל הקבצים בתיקיה המקורית
    $sourceFiles = Get-ChildItem -Path "$mountDrive\*" -Recurse
    foreach ($file in $sourceFiles) {
        # בודק אם מדובר בקובץ ולא בתיקייה
        if (-not $file.PSIsContainer) {
            # יצירת נתיב ביעד שמכבד את מבנה התיקיות
            $destinationPath = Join-Path -Path $targetDirectory -ChildPath $file.FullName.Substring($mountDrive.Length)
            
            # יצירת תיקייה ביעד אם היא לא קיימת
            $destinationFolder = Split-Path -Path $destinationPath -Parent
            if (-not (Test-Path -Path $destinationFolder)) {
                New-Item -ItemType Directory -Path $destinationFolder
            }
            
            # העתקת הקובץ ליעד
            Copy-Item -Path $file.FullName -Destination $destinationPath -Force -ErrorAction Stop
            Write-Host "File $($file.FullName) copied/updated successfully."
        }
    }
    Write-Host "All files copied/updated successfully from $mountDrive to $targetDirectory"
} catch {
    Write-Error "Failed to copy files. Error: $_"
}



# Optionally, unmount the file share after copying
try {
    Remove-PSDrive -Name "L"
    Write-Host "Drive L: unmounted successfully."
} catch {
    Write-Error "Failed to remove the drive. Error: $_"
}


# Disable SMB2 protocol after the file copy operation
Set-SmbServerConfiguration -EnableSMB2Protocol $false
Write-Host "SMB2 protocol has been disabled."