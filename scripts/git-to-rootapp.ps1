# הגדרת כתובת ה-URL של קובץ ה-ZIP מ-GitHub
$githubRepoUrl = "https://github.com/BezeqintUCCollab/webapp-extentions/archive/refs/heads/main.zip"

# הגדרת נתיב תיקיית ה-Temp
$tempFolder = "C:\temp"

# בדיקה אם תיקיית temp קיימת, ואם לא, יצירתה
if (-not (Test-Path -Path $tempFolder)) {
    New-Item -Path $tempFolder -ItemType Directory
}

# הגדרת נתיב תיקיית ה-IIS
$destinationFolder = "C:\inetpub\wwwroot"

# הורדת קובץ ה-ZIP ל-C:\temp
Invoke-WebRequest -Uri $githubRepoUrl -OutFile "$tempFolder\webapp.zip"

# חליצה של קובץ ה-ZIP ל-C:\temp
Expand-Archive -Path "$tempFolder\webapp.zip" -DestinationPath $tempFolder -Force

# העתקת הקבצים מתוך תיקיית files-for-webapp ישירות ל-wwwroot
$sourceFolder = Join-Path -Path $tempFolder -ChildPath "webapp-extentions-main\files-for-webapp\"
Copy-Item -Path "$sourceFolder*" -Destination $destinationFolder -Recurse -Force

# הסרת קובץ ה-ZIP והתיקיה הזמנית שנוצרה
Remove-Item -Path "$tempFolder\webapp.zip" -Force
Remove-Item -Path "$tempFolder\webapp-extentions-main" -Recurse -Force

# הגדרת הרשאות לקריאה וכתיבה על הקבצים
$acl = Get-Acl "$destinationFolder"
$acl.SetAccessRuleProtection($true, $false) # מגן על ההגדרות
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "Read,Write", "Allow")
$acl.AddAccessRule($accessRule)
Set-Acl "$destinationFolder" $acl
