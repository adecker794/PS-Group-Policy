#Lines 2+3, gets the date and starts a transcript
$today = (Get-Date).ToString('yyyyMMddhhmm')
Start-Transcript -Path c:\temp\scripts\transcripts\$today"restartornot".txt

#Pulling the computers from a text file
$computers = Get-Content "c:\temp\scripts\newgpo\computers.txt"


#This is what determines which version to check for.
$searchtext = "Success"

###This is where the script actually checks the validity of the gpovariable file
###It checks the gpovariable file, which is created by the running of gpo
###If it finds the file it looks for a string inside which determine GPO's success
###If it finds that string it continues on, if it doesnt find that file then it will attempt to restart the machine
Write-Host 'Starting GPRESULT validity check'
foreach ($computer in $computers)
{
    $file = "\\$computer\C$\temp\gpovariable.txt"

    if (Test-Path $file)
    {
        if (Get-Content $file | Select-String $searchtext -quiet)
        {
            Write-Host "$computer : Success"
            Continue
            
        }
        else
        {
            Write-Host "$computer : Failure"  
            Invoke-Command -ComputerName $computer -ScriptBlock {powershell.exe shutdown /r /t 0 /f }
            del \\share\temp\gpo\*$computer*
            Write-Host "Shutdown and GPO deletion initiated on $computer, moving to next computer" 
            Continue
        }
    }
    else
    {
        Write-Host "$computer : canot read file: $file"
        Continue
    }
}


Stop-Transcript