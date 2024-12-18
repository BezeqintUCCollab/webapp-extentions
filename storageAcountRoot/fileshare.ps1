# פרמטרים
$storageAccountName = "shdr"
$storageAccountKey = $env:accessKey
$containerName = "wwwroot"
$destinationFolder = "C:\inetpub\wwwroot"  # או המיקום של תיקיית ה-wwwroot שלך

# יצירת קונטקסט לאחסון
$context = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# קבלת רשימת הבלובים (קבצים) ב-container
$blobs = Get-AzStorageBlob -Container $containerName -Context $context

# לולאת העתקה
foreach ($blob in $blobs) {
    $localFilePath = Join-Path -Path $destinationFolder -ChildPath $blob.Name

    # בדוק אם הקובץ כבר קיים ב-wwwroot
    if (-not (Test-Path -Path $localFilePath)) {
        # העתק את הקובץ מה-storage ל-wwwroot
        Write-Host "Copying $($blob.Name) to $destinationFolder"
        Get-AzStorageBlobContent -Container $containerName -Blob $blob.Name -Destination $localFilePath -Context $context
    } else {
        Write-Host "$($blob.Name) already exists, skipping..."
    }
}

Write-Host "File copy process completed!"
