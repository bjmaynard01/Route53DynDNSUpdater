# Route53 Dynamic Record Updater

The intent of this project is to emulate Dynamic DNS updaters (such as DynDNS), but to make it functional with Amazon's Route53 service in AWS. Specifically, it's designed to update every record in a hosted zone that are both "A" records and that match the IP of a previous run, but do not match a currently dynamically assigned address. In effect, the PS1 script can be set to run as a scheduled task to automatically get the external IP of the host it's running on, then check the target hosted zone and update IP's that should match but don't.

## Getting Started

Install the AWS Tools and SDK for .Net (includes PowerShell module)
Have an account and generate access keys for an account with permissions to modify resource record sets in Route53
Pull keys from AWS and store in a CSV file somewhere to be used by the script
Run/Modify AWS-Route53.ps1 from PowerShell with required parameters. The first run must be completed with administrative permissions to setup event logs.

### Prerequisites

PowerShell (v5.0)
[AWS Tools for Windows](http://sdk-for-net.amazonwebservices.com/latest/AWSToolsAndSDKForNet.msi)

### Parameters

#### CSVPath
Path to CSV file that contains key information for account to be used to update records in AWS.

#### ProfileName
Name of profile to store credentials as for subsequent calls to AWS API.

#### TargetDomain
Domain name of hosted zone being targeted, trailing dot "." added automatically.

#### IPFile
Path and name of text file to store/pull past IP information in.

### Usage
From a powershell prompt in the location of the cloned repository, run the following command

```
AWS-Route53.ps1 -CSVPath C:\<wherever CSV file is>\<csvfilename>.csv -ProfileName <name of profile to store creds as> -TargetDomain "example.com" -IPFile C:\<path to txt file>\<file>.txt
```
Example:
```
&"AWS-Route53.ps1" -CSVPath "C:\Users\Public\Route53\accessKeys.csv" -ProfileName "route53api" -TargetDomain "startrekfans.com" -IPFile "C:\Users\Public\Route53\oldIP.txt"
```

### Scheduled Task
To run this as a scheduled task once you've successfully tested against your desired hosted zone, simply create a scheduled task in Windows. The "action" of the task should be as follows:
```
"Program/Script:" powershell.exe
Add arguments: powershell.exe C:\Users\Public\Documents\Projects\PowerShell\Route53\AWS-Route53.ps1 -CSVPath C:\Users\Public\Documents\Projects\PowerShell\Route53\accessKeys.csv -ProfileName r53api -TargetDomain maynardfolks.com -IPFile C:\Users\Public\Documents\Projects\PowerShell\Route53\oldIP.txt
```