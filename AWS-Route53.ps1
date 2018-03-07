Param (
    [parameter(Mandatory=$true)]$CSVPath,
    [parameter(Mandatory=$true)]$ProfileName,
    [parameter(Mandatory=$true)]$TargetDomain,
    [parameter(Mandatory=$true)]$IPFile
)

#Build credentials
$creds = Import-Csv $CSVPath
$AccessKeyID = $creds.'Access key ID'
$AccessKeySecret = $creds.'Secret access key'
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

Set-AWSCredentials -StoreAs $ProfileName -AccessKey $AccessKeyID -SecretKey $AccessKeySecret

#Get current external ip from ipinfo.io
$currentIP = (Invoke-RestMethod http://ipinfo.io/json).ip

#Establish storage location to keep "old IP" for comparison
$oldIPPath = $IPFile

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
    $TargetDomain = $TargetDomain + "."
    #Get ZoneId dynamically from AWS instead of hard-coding
    $ZoneId = ((Get-R53HostedZoneList -StoredCredentials $ProfileName | Where-Object {$_.Name -eq "$TargetDomain"}).Id).Substring(12)

    #Build record set from hosted zone selected previously
    $RecordSets = (Get-R53ResourceRecordSet -HostedZoneId $ZoneId -StoredCredentials $ProfileName).ResourceRecordSets

    foreach($Record in $RecordSets) {
        $IP = ($Record.ResourceRecords).Value
        $Type = $Record.Type
        $RecordName = $Record.Name
        if($Type -eq "A" -and $IP -like $oldIP) {
            $Change = New-Object Amazon.Route53.Model.Change
            $Change.Action = "UPSERT"
            $Change.ResourceRecordSet = $Record
            $Change.ResourceRecordSet.Name = $Record.Name
            $Change.ResourceRecordSet.ResourceRecords.Clear()
            $Change.ResourceRecordSet.ResourceRecords.Add(@{Value=$currentIP})
            Edit-R53ResourceRecordSet -HostedZoneId $ZoneId -ChangeBatch_Comment "Updated from AWS-Route53.ps1" -ChangeBatch_Change $Change -StoredCredentials $ProfileName
            Write-EventLog -LogName Route53 -Source "Route53 Updater" -EntryType Warning -EventID 1001 -Message "Updated Record: $RecordName to the new IP: $currentIP"
        }
    }

    #Change out "old IP" for "new IP" in file for comparison on future runs, and log the change
    (Get-Content $oldIPPath).Replace($oldIP, $currentIP) | Set-Content $oldIPPath
    Write-EventLog -LogName "Route53" -Source "Route53 Updater" -EntryType Information -EventId 10 -Message "Removed $oldIP from File to reflect new IP of: $currentIP"
}