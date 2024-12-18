Invoke-WebRequest -Uri https://aka.ms/installazurecliwindowsx64 -OutFile c:\temp\AzureCLI.msi
Start-Process msiexec.exe -ArgumentList '/I c:\AzureCLI.msi /quiet' -NoNewWindow -Wait


Install-Module -Name Az -AllowClobber -Force -Scope CurrentUser
Connect-AzAccount -TenantId fc3bbf71-756c-402b-86ea-bc760d64f0f7

Connect-AzAccount -TenantId fc3bbf71-756c-402b-86ea-bc760d64f0f7 -UseDeviceAuthentication