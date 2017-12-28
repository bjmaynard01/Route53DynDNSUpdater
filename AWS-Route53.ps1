#Build credentials
$creds = Import-Csv "./accessKeys.csv"
$AccessKeyID = $creds.AccessKeyId
$AccessKeySecret = $creds.SecretKey
#Set Error Action so that catching is possible
$ErrorActionPreference = "Stop"

#Conditionally import module
if(!(Get-Module -Name AWSPowerShell)) {
    try {
        Import-Module AWSPowerShell
    }
    catch {
        Write-EventLog -LogName "Route53" -Source "Route53 Updater" -EntryType Error -Message $_ -EventId 9
    }
}

#Setup Logging
if((Get-EventLog -List).Log -notcontains "Route53") {
    try {
        New-EventLog -LogName "Route53" -Source "Route53 Updater"
    }
    catch {
        Write-EventLog -LogName "Route53" -Source "Route53 Updater" -EntryType Error -Message $_ -EventId 10
    }
}

#Test for previously stored administrator credentials, and if not found, build them
if(!(Get-AWSCredentials -ProfileName administrator)) {
    Set-AWSCredential -AccessKey $AccessKeyID -SecretKey $AccessKeySecret -StoreAs administrator
}

#Get current external ip from ipinfo.io
$currentIP = (Invoke-RestMethod http://ipinfo.io/json).ip

#Establish storage location to keep "old IP" for comparison
$oldIPPath = "./oldIP.txt"

#Test for existence of stateful file, and create if needed
if(!(Test-Path $oldIPPath)) {
    New-Item -Path $oldIPPath
    Write-EventLog -LogName "Route53" -Source "Route53 Updater" -EntryType Information -EventId 1 -Message "Creating text file to track IP address between runs."
}

$oldIP = Get-Content $oldIPPath 

#If storage file empty, add current IP to it for comparison on next run
if(!($oldIP)) {
    Add-Content $oldIPPath $currentIP
    Write-EventLog -LogName "Route53" -Source "Route53 Updater" -EntryType Information -EventId 2 -Message "Updating IP address in text file to match new external IP."
}

if($currentIP -match $oldIP) {
    #No change in IP detected, log and exit
    Write-EventLog -LogName "Route53" -Source "Route53 Updater" -EntryType Information -EventId 0 -Message "Current IP matched Old IP on this run, exiting."
    Exit
}

else {
    #Ip address has been changed, time to update the records in AWS...don't forget logging

    #Get ZoneId dynamically from AWS instead of hard-coding
    $ZoneId = ((Get-R53HostedZoneList -ProfileName administrator | Where-Object {$_.Name -eq "maynardfolks.com."}).Id).Substring(12)

    #Build record set from hosted zone selected previously
    $Records = (Get-R53ResourceRecordSet -HostedZoneId $ZoneId -ProfileName administrator).ResourceRecordSets

    foreach($Record in $Records) {
        $Name = $Record.Name
        $Value = ($Record.ResourceRecords).Value
        $Type = $Record.Type
        if($Type -eq "A" -and $Value -like $oldIP) {
            
        }
    }

    #Change out "old IP" for "new IP" in file for comparison on future runs, and log the change
    (Get-Content $oldIPPath).Replace($oldIP, $currentIP) | Set-Content $oldIPPath
    Write-EventLog -LogName "Route53" -Source "Route53 Updater" -EntryType Information -EventId 10 -Message "Removed $oldIP from File to reflect new IP of: $currentIP"
}