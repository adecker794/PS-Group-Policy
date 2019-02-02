    #Grabs todays date and starts old file deletion
    $today = (Get-Date).ToString('hhmm')
    Write-Host "Starting File Deletion, time is $today"

    $gpresult = "c:\temp\gpresult.txt"
    $file = Get-ChildItem $gpresult -Directory -ErrorAction SilentlyContinue
    If ($file) 
    { Write-Output "Deleting GPRESULT"
    del c:\temp\gpresult.txt -Recurse }
    else
    { Write-Output "No GPRESULT to delete"}

    $gpresult = "c:\temp\gpresult.txt"
    $file = Get-ChildItem $gpresult -Directory -ErrorAction SilentlyContinue
    If ($file) 
    { Write-Output "Deleting GPRESULT"
    del c:\temp\gpresult.txt }
    else
    { Write-Output "No GPRESULT to delete"}

    $kb1 = "c:\temp\kb1.txt"
    $file = Get-ChildItem $kb1 -Directory -ErrorAction SilentlyContinue
    If ($file) 
    { Write-Output "Deleting KB1"
    del c:\temp\kb1.txt }
    else
    { Write-Output "No KB1 to delete"}

    $kb = "c:\temp\KB.txt"
    $file = Get-ChildItem $kb -Directory -ErrorAction SilentlyContinue
    If ($file) 
    { Write-Output "Deleting KB"
    del c:\temp\KB.txt }
    else
    { Write-Output "No KB to delete"}

    $sysinfo = "c:\temp\sysinfo.txt"
    $file = Get-ChildItem $sysinfo -Directory -ErrorAction SilentlyContinue
    If ($file) 
    { Write-Output "Deleting SYSINFO"
    del c:\temp\sysinfo.txt }
    else
    { Write-Output "No SYSINFO to delete"}

    $sn = "c:\temp\sn.txt"
    $file = Get-ChildItem $sn -Directory -ErrorAction SilentlyContinue
    If ($file) 
    { Write-Output "Deleting SN"
    del c:\temp\sn.txt }
    else
    { Write-Output "No SN to delete"}
 
   
    
    ## Writes out the hotfix variable for the KB in name
    $today = (Get-Date).ToString('hhmm')
    Write-Host "Starting Hotfix Creation, time is $today"
    Get-Hotfix | Select-Object HotFixID, InstalledOn | sort Installedon | Select-Object HotFixID -Last 1 >> c:\temp\kb1.txt
    Get-Hotfix | Select-Object HotFixID, InstalledOn | sort Installedon | Select-Object InstalledOn -Last 1 >> c:\temp\kb1.txt
    #Get-Hotfix | Select-Object HotFixID, InstalledOn | sort Installedon  >> c:\temp\KB.txt
    (Get-Content C:\temp\kb1.txt) | 
    Foreach-Object {$_ -replace "/", "_"} | 
    Set-Content C:\temp\kb1.txt
    (Get-Content C:\temp\kb1.txt) |
    Foreach-Object {$_ -replace "\s", ''} | 
    Set-Content C:\temp\kb1.txt
    $kb1 = Get-Content c:\temp\kb1.txt
    $kbID = $kb1[3]
    $Kb3 = $kb1[9]

    if ($kb3.length -eq 17){
            $kbdate = $kb3.Substring(0, 7)
        }
    if ($kb3.length -eq 18){
            $kbdate = $kb3.Substring(0, 8)
        }
    if ($kb3.length -eq 19){
            $kbdate = $kb3.Substring(0, 9)
        }
    if ($kb3.length -eq 20){
            $kbdate = $kb3.Substring(0, 10)
        }

    Write-Output $kbID
    Write-Output $kbdate

    ## Goes through each user on the computer, sorted by most recent logged in, pulls the first one that has rsop data and makes a gpresult.txt, therefore creating a more accurate gpresult
    $today = (Get-Date).ToString('hhmm')
    Write-Host "Starting GPO Job, time is $today"
    Write-Host 'Starting GPO Job'
    $Job = Start-Job -ScriptBlock {

    Invoke-Command  -ScriptBlock {
    #
    $computer = $env:COMPUTERNAME
    Get-ChildItem "\\$computer\c$\Users" | Sort-Object LastWriteTime -Descending | Select-Object Name  > c:\temp\users.txt
    $users1 = Get-Content c:\temp\users.txt
    $lines =  Get-Content c:\temp\users.txt | Measure-Object
    $lines = $lines.Count
    #write-output $lines
    $users = $users1[3..$lines]
    write-host 'Finished Creating Users File'
    $gpresult = "c:\temp\gpresult.txt"
    $file = Get-ChildItem $gpresult -Directory -ErrorAction SilentlyContinue
    If ($file) 
        { Write-Output "Deleting GPRESULT"
        del c:\temp\gpresult.txt }
    else
        { Write-Output "No GPRESULT to delete"}

    foreach ($user in $users) {
    $gpresult = "c:\temp\gpresult.txt"
    $file = Get-ChildItem $gpresult -Directory -ErrorAction SilentlyContinue
        if ($file.length -gt 300kb)  {

        
        } 
        else {
        $user1 = $user
        $user1 = $user1 -replace '\s',''
        Write-Output $user1
        Write-Output "Writing $user1 to gpresult"
        gpresult /scope COMPUTER /user $user1 /v > C:\temp\gpresult.txt
     
     }      
    }
    #
    } 


    }
    $Job | Wait-Job -Timeout 180
    $Job | Receive-Job
    $Job | Stop-Job

    Start-Sleep -Seconds 2

    $gpresult = "c:\temp\gpresult.txt"
    $file = Get-ChildItem $gpresult -Directory -ErrorAction SilentlyContinue
        if ($file.length -gt 300kb)  {
        'Success' > c:\temp\gpovariable.txt
        Write-Host 'GPOVariable Success'
        
        } 
        else
        {
        'Failed' > c:\temp\gpovariable.txt
        Write-Host 'GPOVariable Failed'
        }

    Start-Sleep -Seconds 2

    ##Writes out Variable for when gpo last ran in name
    $today = (Get-Date).ToString('hhmm')
    Write-Host "Starting GPO last ran entry, time is $today"

    (Get-Content C:\temp\gpresult.txt) | 
    Foreach-Object {$_ -replace "/", "_"} | 
    Set-Content C:\temp\gpresult.txt
    (Get-Content C:\temp\gpresult.txt) | 
    Foreach-Object {$_ -replace ":", "_"} | 
    Set-Content C:\temp\gpresult.txt
    $gpo = Get-Content c:\temp\gpresult.txt
    $gpo1 = $gpo[22]
    

    if ($gpo1.length -eq 65){
        $gpotime = $gpo1.Substring(39)
        #$gpotd = $gpodt.Substring(10, 29)
        #$gpotime = $gpotd.Substring(5, 24)
        }
    if ($gpo1.length -eq 64){
        $gpotime = $gpo1.Substring(39)
        #$gpotd = $gpodt.Substring(10, 29)
        #$gpotime = $gpotd.Substring(5, 24)
        }
    if ($gpo1.length -eq 63){
        $gpotime = $gpo1.Substring(39)
        #$gpotd = $gpodt.Substring(10, 28)
        #$gpotime = $gpotd.Substring(5, 23)
        } 
     if ($gpo1.length -eq 62){
        $gpotime = $gpo1.Substring(39)
        #$gpotd = $gpodt.Substring(10, 28)
        #$gpotime = $gpotd.Substring(5, 23)
        } 
    if ($gpo1.length -eq 61){
        $gpotime = $gpo1.Substring(39)
        #$gpotd = $gpodt.Substring(10, 28)
        #$gpotime = $gpotd.Substring(5, 23)
        }
    if ($gpo1.length -eq 60){
        $gpotime = $gpo1.Substring(39)
        #$gpotd = $gpodt.Substring(10, 28)
        #$gpotime = $gpotd.Substring(5, 23)
        }
    

    Write-Output $gpotime

    ##Writes out Variable for when system last boot in name

    systeminfo >> c:\temp\sysinfo.txt
    (Get-Content C:\temp\sysinfo.txt) | 
    Foreach-Object {$_ -replace ":", "_"} | 
    Set-Content C:\temp\sysinfo.txt
    (Get-Content C:\temp\sysinfo.txt) | 
    Foreach-Object {$_ -replace "/", "_"} | 
    Set-Content C:\temp\sysinfo.txt
    $boot = Get-Content c:\temp\sysinfo.txt
    $boot1 = $boot[11]
    

    if ($boot1.length -eq 47){
            $boot2 = $boot1.Substring(20, 17)
            $boot3 = $boot2.Substring(6, 9)
        }
    if ($boot1.length -eq 48){
            $boot2 = $boot1.Substring(20, 21)
            $boot3 = $boot2.Substring(7, 9)
        }
    if ($boot1.length -eq 49){
            $boot2 = $boot1.Substring(20, 17)
            $boot3 = $boot2.Substring(6, 11)
        }

    Write-Output $boot3

    ##Writes out Variable for systems SN in name
    $today = (Get-Date).ToString('hhmm')
    Write-Host "Starting SN Creation, time is $today"

    wmic bios get serialnumber >> c:\temp\sn.txt
    (Get-Content C:\temp\sysinfo.txt) | 
    Foreach-Object {$_ -replace ":", "_"} | 
    Set-Content C:\temp\sysinfo.txt
    (Get-Content C:\temp\sysinfo.txt) | 
    Foreach-Object {$_ -replace "/", "_"} | 
    Set-Content C:\temp\sysinfo.txt
    $sn = Get-Content c:\temp\sn.txt
    $sn1 = $sn[2]
    $sn2 = $sn1.substring(0, 7)

    Write-Output $sn2

    ## Goes through each user on the computer, sorted by most recent logged in, pulls the first one that has rsop data and makes a gpresult.txt, therefore creating a more accurate gpresult
    $today = (Get-Date).ToString('hhmm')
    Write-Host "Starting GPO Job, time is $today"    
    Write-Host 'Starting GPO Job'
    $Job = Start-Job -ScriptBlock {

    Invoke-Command  -ScriptBlock {
    #
    $computer = $env:COMPUTERNAME
    Get-ChildItem "\\$computer\c$\Users" | Sort-Object LastWriteTime -Descending | Select-Object Name  > c:\temp\users.txt
    $users1 = Get-Content c:\temp\users.txt
    $lines =  Get-Content c:\temp\users.txt | Measure-Object
    $lines = $lines.Count
    #write-output $lines
    $users = $users1[3..$lines]
    write-host 'Finished Creating Users File'
    $gpresult = "c:\temp\gpresult.txt"
    $file = Get-ChildItem $gpresult -Directory -ErrorAction SilentlyContinue
    If ($file) 
        { Write-Output "Deleting GPRESULT"
        del c:\temp\gpresult.txt }
    else
        { Write-Output "No GPRESULT to delete"}

    foreach ($user in $users) {
    $gpresult = "c:\temp\gpresult.txt"
    $file = Get-ChildItem $gpresult -Directory -ErrorAction SilentlyContinue
        if ($file.length -gt 300kb)  {

        
        } 
        else {
        $user1 = $user
        $user1 = $user1 -replace '\s',''
        Write-Output $user1
        Write-Output "Writing $user1 to gpresult"
        gpresult /scope COMPUTER /user $user1 /v > C:\temp\gpresult.txt
     
     }      
    }
    #
    } 
    }
    $Job | Wait-Job -Timeout 180
    $Job | Receive-Job
    $Job | Stop-Job

    $gpresult = "c:\temp\gpresult.txt"
    $file = Get-ChildItem $gpresult -Directory -ErrorAction SilentlyContinue
        if ($file.length -gt 300kb)  {
        'Success' > c:\temp\gpovariable.txt
        Write-Host 'GPOVariable Success'
        
        } 
        else
        {
        'Failed' > c:\temp\gpovariable.txt
        Write-Host 'GPOVariable Failed'
        }

    ## Grabs windows version and adds it to the beginning of the gpo file
    $today = (Get-Date).ToString('hhmm')
    Write-Host "Starting Windows Version grab, time is $today"
    Get-ComputerInfo -Property Windows* | select WindowsVersion > C:\temp\version.txt
    $ver = get-content 'c:\temp\version.txt'
    $OSversion = $ver[3]
    $OSversion = $OSversion -replace '\s',''
    Write-Host $OSversion

    ## Adds systeminfo, ipconfig, and fsutil to the GPRESULT text file
    $today = (Get-Date).ToString('hhmm')
    Write-Host "Starting Sysinfo, IPConfig, and FSUITL creation, time is $today"
    systeminfo >> c:\temp\gpresult.txt
    ipconfig /all >> c:\temp\gpresult.txt
    fsutil volume diskfree c:\ >>  c:\temp\gpresult.txt

    ## Adds hotfix to the GPRESULT text
    $today = (Get-Date).ToString('hhmm')
    Write-Host "Starting Hotfix Creation, time is $today"
    Get-Hotfix | Select HotFixID, InstalledOn | Sort-Object InstalledOn >> c:\temp\gpresult.txt
    
    ## Adds bios serialnumber to the GPRESULT text
    $today = (Get-Date).ToString('hhmm')
    Write-Host "Starting SN add, time is $today"
    wmic bios get serialnumber >> c:\temp\gpresult.txt

    ## Variables for the name
    $today = (Get-Date).ToString('hhmm')
    Write-Host "Starting ID add, time is $today"
    $ID = Get-Content C:\temp\ID.gpo
    "ComputerID=$ID" >> c:\temp\gpresult.txt
    Write-Output $ID
    
    "    " >> c:\temp\gpresult.txt

    "ComputerName:$env:computername" >> c:\temp\gpresult.txt

    "    " >> c:\temp\gpresult.txt
    
    #Writing Monitors attached to computer to gpresult.txt
    $Monitors = Get-WmiObject WmiMonitorID -Namespace root\wmi
    $LogFile = "C:\temp\gpresult.txt"
    "Manufacturer,Name,Serial" | Out-File $LogFile -append

    ForEach ($Monitor in $Monitors) {
    
	    $Manufacturer = ($Monitor.ManufacturerName -notmatch 0 | ForEach{[char]$_}) -join ""
	    $Name = ($Monitor.UserFriendlyName -notmatch 0 | ForEach{[char]$_}) -join ""
	    $Serial = ($Monitor.SerialNumberID -notmatch 0 | ForEach{[char]$_}) -join ""
	
   
	    "$Manufacturer,$Name,$Serial" | Out-File $LogFile -append
        }


    ##Pause to ensure every command is done and wrote to each text file
    #Start-Sleep -s 10

    ## Deletes GPO after variables have been loaded so it understands what it needs to delete. It also deletes the GPO files in the GPO folder so nothing extra gets copied to the share.
    del C:\temp\*$env:computername*
    del C:\temp\gpo\*$env:computername*
    del C:\temp\gpo\actual\*$env:computername*
    del C:\temp\gpo\actual -Recurse
   

    ## Checks for the gpo actual folder, creates if needed.
    $foldername = "c:\temp\gpo\actual"
    if(!(Test-Path $foldername -PathType Container)) { 
    write-host "GPO\ACTUAL not found, creating dir now."
        MKDIR c:\temp\gpo\actual 
    } 
    else {
    Write-Output "GPO\ACTUAL FOUND"
    }

    #This is the copying over to share drive section. 
    Copy-Item C:\temp\gpresult.txt C:\temp\gpo\actual\$OSversion"_GPO_"$gpotime"_"$kbID"_"$kbdate"_"$env:computername"_"$sn2"_boot_"$boot3"_"$ID.gpo


    ## Writes out time
    $time = $((Get-Date).ToString('HH:mm'))
    Write-Output $time
    