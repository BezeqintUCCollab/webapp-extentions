Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile c:\temp\AzureCLI.msi
Start-Process msiexec.exe -ArgumentList '/I c:\AzureCLI.msi /quiet' -NoNewWindow -Wait
