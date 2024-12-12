# הגדרת כתובת ה-URL של GitHub
$githubRepoUrl = "https://raw.githubusercontent.com/<username>/<repo>/main/scripts"

# הורדת הקובץ מה-GitHub
Invoke-WebRequest -Uri "$githubRepoUrl/myfile.txt" -OutFile "C:\inetpub\wwwroot\myfile.txt"

# הגדרת הרשאות לקריאה וכתיבה על הקובץ
$acl = Get-Acl "C:\inetpub\wwwroot\myfile.txt"
$acl.SetAccessRuleProtection($true, $false) # מגן על ההגדרות
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule("IIS_IUSRS", "Read,Write", "Allow")
$acl.AddAccessRule($accessRule)
Set-Acl "C:\inetpub\wwwroot\myfile.txt" $acl