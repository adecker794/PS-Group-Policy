#Lines 2+3, gets the date and starts a transcript
$today = (Get-Date).ToString('yyyyMMddhhmm')
Start-Transcript -Path c:\temp\scripts\transcripts\$today"earlymorninggpo".txt

# This is what gets the list of computers
$computers = Get-Content "C:\temp\scripts\newgpo\computers.txt"
#$computers = 'computer'


#Down to business, this starts by making sure the computer is online
#If no computer is pinged then it writes to the shell indicating that computer can not be reached. 
foreach ($computer in $computers) {
    if (test-Connection -Cn $computer -Count 2 ) {
        

        #Gets date 
        $today = (Get-Date).ToString('hhmm')
        #Writes to host that it is starting GPO job at X time
        Write-Host "Starting $computer at time $today"
        Write-Host "Starting GPO Job on $computer"

        ###The next set of lines starts the job, this is the entirety of the GPO job(on this script)
        ###It makes the dir on the computer, copies gpo files, sets the execution policy, runs the gpo file
        ###Runs the timecheck, if the timecheck is good it copies gpo file to remote share after deleting from remote share
        ###If time check is bad then it just states that and does nothing 
        $Job = Start-Job -ScriptBlock {
        Param($computer)
        Invoke-Command -ComputerName $computer -ScriptBlock {powershell.exe MKDIR c:\temp\gpo  }
        robocopy c:\temp\scripts\newgpo\gpo \\$computer\c$\temp\gpo /S /E  /V /XO /MT:32 /R:2 /W:10
        Write-Host 'Setting Execution Policy'
        Invoke-Command -ComputerName $computer -ScriptBlock {powershell.exe Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted  }
        Write-Host 'Starting Working GPO.ps1'
        Invoke-Command -ComputerName $computer -ScriptBlock {powershell.exe "c:\temp\gpo\workinggpo.ps1" /s } 
        Invoke-Command -ComputerName $computer -ScriptBlock {powershell.exe "c:\temp\gpo\timecheck.ps1" /s }
        } -ArgumentList $computer
        $Job | Wait-Job -Timeout 300
        $Job | Receive-Job
        $Job | Stop-Job
        $file = "\\$computer\C$\temp\gpo\timecheck\OTD.txt"
        $searchtext = "OTDGOOD"

        if (Test-Path $file){
            if (Get-Content $file | Select-String $searchtext -quiet)
        {
            Write-Host "$computer GPO up to date, removing share copy"
            del \\$share\temp\gpo\*$computer*
            Write-Host "Copying GPO to share"
            robocopy \\$computer\c$\temp\gpo\actual \\$share\temp\GPO /S /E /V /XO /MT:32 /R:2 /W:10
            $today = (Get-Date).ToString('hhmm')
            Write-Host "Finishing $computer at time $today"
            Continue

        }
            else
            {
            Write-Host "$computer : GPO file not up to date, doing nothing"
            Continue
            }
            }
        else
        {
        Write-Host "$computer : canot read file: $file"
        Continue
        }
        Invoke-Command -ComputerName $computer -ScriptBlock {powershell.exe Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted  }

    }
        #Write-Host -ForegroundColor Green "Installation successful on $computer"
        #Add-Content C:\temp\Scripts\newgpo\success.csv  "$computer, Success"
        
        



    #Writes to host that the computer is not online 
    else {
        Write-Host -ForegroundColor Red "$computer is not online, GPO failed"
        #Add-Content C:\temp\GPO\failed.csv  "$computer"   
    }
}
   

Stop-Transcript