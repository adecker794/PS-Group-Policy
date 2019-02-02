#Lines 2+3, gets the date and starts a transcript
$today = (Get-Date).ToString('yyyyMMddhhmm')
Start-Transcript -Path c:\temp\scripts\transcripts\$today"midmorninggpo".txt

#Pulling the computers from a text file, deleting older csv files so proper output results are shown
$Computers = Get-Content "C:\temp\scripts\newgpo\computers.txt"
$OutFile = "C:\temp\scripts\failedgpo\failed.csv"
$today = (Get-Date).ToString('yyyyMMdd')
del C:\temp\scripts\failedgpo\failed.csv
del C:\temp\scripts\failedgpo\success.csv
#Erase an existing output file so as not to duplicate data


#Starting the foreach loop
foreach ($Computer in $Computers){
    #test to make sure the file exists
    if (test-path c:\temp\gpo\*$computer*){
        #Get the CreationTime value from the file
        $FileDate = (Get-ChildItem c:\temp\gpo\*$computer*).LastWriteTime
            ###Compares the file date to todays date and adds the list to a success or failed file
            ###Success gets ignored and failed gets piped down to the rest of the script
            if($FileDate.ToString('yyyyMMdd') -eq $today){
                "$Computer" | Add-Content "c:\temp\scripts\failedgpo\success.csv"
                }
            else{
            "$Computer" | Add-Content $OutFile
            }
    #Write the computer name and File date separated by a unique character you can open in Excel easy with"
    }
    else
    {
    #File did not exist, write that to the log also
    "$Computer" | Add-Content $OutFile 
     
    }
}

# This is what gets the list of computers
$computers = Get-Content "C:\temp\scripts\failedgpo\failed.csv"


#PROPER COMMENTS FOR THIS SECTION ARE IN THE c:\temp\Scripts\newgpo\rungpo.ps1 file
foreach ($computer in $computers) {
    if (test-Connection -Cn $computer -Count 2 ) {  
        $today = (Get-Date).ToString('hhmm')
     
        Write-Host "Starting $computer at time $today"
        Write-Host "Starting GPO Job on $computer"
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
            }
            }
        else
        {
        Write-Host "$computer : canot read file: $file"
        }
        Invoke-Command -ComputerName $computer -ScriptBlock {powershell.exe Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Restricted  }

    }
        
        
        
#These lines write to a file if the computer is not reached by the ping test.
     
    else {
        Write-Host -ForegroundColor Red "$computer is not online, Install failed"
        #Add-Content C:\temp\GPO\failed.csv  "$computer"   
    }
}

#This section does the same as the first section, it runs again so it can get a final count to add to the csv files for later examination
$Computers = Get-Content "C:\temp\scripts\newgpo\computers.txt"
$OutFile = "C:\temp\scripts\failedgpo\failed.csv"
$today = (Get-Date).ToString('yyyyMMdd')
del C:\temp\scripts\failedgpo\failed.csv
del C:\temp\scripts\failedgpo\success.csv
#Erase an existing output file so as not to duplicate data
#out-file -filepath $OutFile

foreach ($Computer in $Computers)
{
    
if (test-path c:\temp\gpo\*$computer*)  #test to make sure the file exists
    {
    #Get the CreationTime value from the file
    $FileDate = (Get-ChildItem c:\temp\gpo\*$computer*).LastWriteTime
        if($FileDate.ToString('yyyyMMdd') -eq $today){
            "$Computer" | Add-Content "c:\temp\scripts\failedgpo\success.csv"
            }
        else{
        "$Computer" | Add-Content $OutFile
        }
    #Write the computer name and File date separated by a unique character you can open in Excel easy with"
    }
    else
    {
    #File did not exist, write that to the log also
    "$Computer" | Add-Content $OutFile 
     
    }
}

Stop-Transcript