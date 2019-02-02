#Gets todays date
$today = (Get-Date).ToString('yyyyMMdd')

#Deleting older files
del c:\temp\gpo\timecheck -Recurse

#Setting computer variable
$computer = $env:COMPUTERNAME


## Checks for the gpo actual folder, creates if needed.
$foldername = "c:\temp\gpo\timecheck"
    if(!(Test-Path $foldername -PathType Container)) { 
      write-host "Timecheck not found, creating dir now."
      MKDIR c:\temp\gpo\timecheck
    } 
    else {
    Write-Output "Timecheck FOUND"
    }

###Tests the file to see if the last write time was today, if it was then GPO succeeded
###If the file is older then GPO failed and it will add OTDNOTGOOD into the OTD text file for the restart script to pick up and restart the machine
if (test-path c:\temp\gpo\actual\*$computer*)  
    {
    #Get the CreationTime value from the file
    $FileDate = (Get-ChildItem c:\temp\gpo\actual\*$computer*).LastWriteTime
        if($FileDate.ToString('yyyyMMdd') -eq $today){
            "OTDGOOD" | Add-Content "c:\temp\gpo\timecheck\OTD.txt"
            }
        else{
        del "c:\temp\timecheck\OTD.txt"
        "OTDNOTGOOD" | Add-Content "c:\temp\gpo\timecheck\OTD.txt"
        }

    #Write the computer name and File date separated by a unique character you can open in Excel easy with"
    }
    else
    {
    #File did not exist, write that to the log also
    "$Computer" | Add-Content "c:\temp\gpo\timecheck\OTD.txt" 
     
    }

