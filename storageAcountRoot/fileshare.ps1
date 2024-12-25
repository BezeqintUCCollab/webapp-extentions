# Variables
$targetDirectory = "C:\inetpub\wwwroot"
$mountDrive = "L:"  # The drive letter where the file share is mounted

# Enable SMB2 protocol before performing any operations
Set-SmbServerConfiguration -EnableSMB2Protocol $true -Force

# Ensure that the Managed Identity has permission to access the file share
$storageAccountName = "shdr"  # Replace with your actual storage account name
$fileShareName = "webappfiles"  # Replace with your actual file share name

# Get the token for accessing the storage account using Managed Identity
$token = (Invoke-RestMethod -Uri "http://169.254.169.254/metadata/identity/oauth2/token?resource=https://storage.azure.com/" -Headers @{Metadata="true"} -Method GET).access_token

# Prepare to mount the Azure File Share using the retrieved token
$storageUri = "\\$storageAccountName.file.core.windows.net\$fileShareName"

# Test connection to the Azure File Share (port 445)
$connectTestResult = Test-NetConnection -ComputerName "$storageAccountName.file.core.windows.net" -Port 445
if ($connectTestResult.TcpTestSucceeded) {
    # Use the retrieved token to mount the file share (no need for cmdkey)
    New-PSDrive -Name "L" -PSProvider FileSystem -Root $storageUri -Persist -Credential (New-Object System.Management.Automation.PSCredential('dummy', (ConvertTo-SecureString $token -AsPlainText -Force)))
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
    $sourceFiles = Get-ChildItem -Path "$mountDrive\*" -Recurse
    foreach ($file in $sourceFiles) {
        if (-not $file.PSIsContainer) {
            $destinationPath = Join-Path -Path $targetDirectory -ChildPath $file.FullName.Substring($mountDrive.Length)
            
            $destinationFolder = Split-Path -Path $destinationPath -Parent
            if (-not (Test-Path -Path $destinationFolder)) {
                New-Item -ItemType Directory -Path $destinationFolder
            }
            
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
Set-SmbServerConfiguration -EnableSMB2Protocol $false -Force

Write-Host "SMB2 protocol has been disabled."
