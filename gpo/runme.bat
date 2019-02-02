cd c:\temp\gpo
powershell.exe Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted 
powershell .\timecheck.ps1
powershell .\workinggpo.ps1
robocopy c:\temp\gpo\actual \\server\location /S /E /V /XO /MT:32 /R:2 /W:10
powershell.exe Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted