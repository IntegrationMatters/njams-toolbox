<#
.SYNOPSIS
    Outputs payload data from activities of process executions of a given process and a period of time.
.DESCRIPTION
    This script outputs the payload data into files from activities of process executions monitored with nJAMS of a particular process name and a given period of time.

.PARAMETER instance
    Enter the nJAMS instance URL, e.g. "http://localhost:8080/njams". This parameter is mandatory.

.PARAMETER username
    Enter username of the nJAMS instance account. Default is "admin".

.PARAMETER password
    Enter password of the nJAMS instance account. Default is "admin".

.PARAMETER processName
    Specifies the name of the process to search for. This parameter is mandatory. 

.PARAMETER fromTimestamp
    Specifies from when to search.

.PARAMETER toTimestamp
    Specifies until when to search. This parameter is optional. Omit this parameter to search for executions until now.

.PARAMETER size
    Limits the number hits. Default is 1000.

.EXAMPLE
    ./getPayload.ps1 -instance "http://vslnjams03:38080/njams" -user "admin" -password "admin" -from "2022-10-10T08:00:00.000" -to "2022-10-10T12:00:00.000" -process "Starter_C1_SendOrder.process"
    Searches for process 'Starter_C1_SendOrder' and outputs the results into individual files in the current directory.

.LINK
    https://github.com/integrationmatters/njams-toolbox
    https://www.integrationmatters.com/

.NOTES
    Version:    1.0.0
    Copyright:  (c) Integration Matters
    Date:       October 2022
#>


param (
    [Parameter(Mandatory=$true)][string]$instance = "http://vslnjams03:38080/njams",
    [string]$username = "admin",
    [string]$password = "admin",
    [string][Alias("process")]$processName = "OrderServices/C1/Starter_C1_SendOrder.process",
    [string][Alias("from")]$fromTimestamp = "2022-10-10T07:00:00.000",
    [string][Alias("to")]$toTimestamp = "2022-10-10T07:03:00.000",
    [string]$size = "1000"
)

# Change policy to trust all certificates, just in case you are using TLS/HTTPS:
# Use -SkipCertificateCheck in "Invoke-RestMethod" instead, when you are on PScore.
# For Windows PowerShell 5 use the following:
if ($PSVersionTable.PSEdition -ne "Core") {
Add-Type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
	public bool CheckValidationResult(
	ServicePoint srvPoint, X509Certificate certificate,
	WebRequest request, int certificateProblem) {
		return true;
	}
}
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
# Set Tls versions
$allProtocols = [System.Net.SecurityProtocolType]'Ssl3,Tls,Tls11,Tls12'
[System.Net.ServicePointManager]::SecurityProtocol = $allProtocols
}

# General header for requests:
$myHeader = @{
    "Authorization" = "Basic"+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('"$username:$password"')) 
}

# (1) Login as admin:
#
$myBody = '{ "username": "' + $username + '" , ' + '"password": "' + $password + '" }'
$mySession = $null #empty variable session
try {
	if ($PSVersionTable.PSEdition -eq "Core") {
		$userId = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -Body $myBody -uri "$instance/api/usermanagement/authentication" -SessionVariable mySession
	}
	else {
		$userId = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -Body $myBody -uri "$instance/api/usermanagement/authentication" -SessionVariable mySession
	}
}
catch {
    write-host "Unable to login into nJAMS instance due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

    Exit
}

# Get Payload from a particular activity (modelId) of a process execution (logId):
function fnGetEventPayload ([string]$logId, [string]$modelId, [string]$instanceId, [string]$fieldName) {

    $myUri = "$instance/api/search/payloadfile/$logId/$modelId/$instanceId/$fieldName"

    # Get payload from specific event/activity:
    try {
        if ($PSVersionTable.PSEdition -eq "Core") {
            $searchObject = Invoke-RestMethod -Method GET -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -uri $myUri -WebSession $mySession
        }
        else {
            $searchObject = Invoke-RestMethod -Method GET -Header $myHeader -ContentType "application/json" -uri $myUri -WebSession $mySession
        }

        return $searchObject.OuterXml
    }
    catch {
        write-host "Script fails due to:" -ForegroundColor Red
        write-host "$_.Exception.Message"

        Exit
    }
}

# Walk through list of activities with payload data of a process instance:
function fnGetActivitiesWithEvents ([string]$logId) {

    # Create request object:
    $requestObject = [PSCustomObject]@{
        "logId" = $logId
    }

    # Convert custom object to JSON:
    $requestBody = $requestObject | ConvertTo-Json

    # Start search and output results:
    try {
        if ($PSVersionTable.PSEdition -eq "Core") {
            $searchObject = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -Body $requestBody -uri "$instance/api/search/activitieswithevents" -WebSession $mySession
        }
        else {
            $searchObject = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -Body $requestBody -uri "$instance/api/search/activitieswithevents" -WebSession $mySession
        } 

        # Loop through activities, where payload data exist:
        foreach ($hit in $searchObject | Where-object { $_.hasPayload -eq "true" }) {

            # Get payload data of current activity:
            $payload = fnGetEventPayload $logId $hit.modelId $hit.instanceId "eventPayload"
            
            # Write payload into file in current folder:
            write-output $payload | Out-File -FilePath "./$($logId)_$($hit.modelId)_$($hit.instanceId).txt"

        }

    }
    catch {
        write-host "Unable to retrieve process instances from given path of nJAMS instance due to:" -ForegroundColor Red
        write-host "$_.Exception.Message"
    
        Exit
    }
}

# Create request object of search:
$requestObject = [PSCustomObject]@{
    "useFollowUpStatus" = "true"
    "usePath" = "true"
    "useStatus" = "true"
    "useTimestamps" = "true"
    "followUpOpen" = "false"
    "followUpComplete" = "false"
    "path" = ">"
    "mainObjectTypeString" = "DO"
    "start" = 0
    "size" = $size
    "queryString" = $('processName:\"' + $processName + '\"')
    "from"= @{
        "field" = "PROCESS_START"
        "timestamp" = $fromTimestamp
    }   
    "to"= @{
        "field" = "PROCESS_START"
        "timestamp" = $toTimestamp
    }   
}

# Convert custom object to JSON:
$requestBody = $requestObject | ConvertTo-Json

# Start search and output results:
try {
    if ($PSVersionTable.PSEdition -eq "Core") {
		$searchObject = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -Body $requestBody -uri "$instance/api/search" -WebSession $mySession
	}
	else {
		$searchObject = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -Body $requestBody -uri "$instance/api/search" -WebSession $mySession
    } 

    $output = @()

    write-output "Output payload data of activities of the following process instances:"

    # Loop through list of results:
    foreach ($hit in $searchObject.hits.hits._source) {
        $item = New-Object PSObject -Property @{
            start = $($hit.timestamp)
            duration = $($hit.duration)
            status = $($hit.status)
            logid = $($hit.logid)
        }

        $output += $item
        write-host $hit.logid, $hit.status, $hit.timestamp

        # Get payload data of any activity of current process instance:
        fnGetActivitiesWithEvents $($hit.logid)
    }

    write-output "Total hits: " $output.count

}
catch {
	write-host "Unable to retrieve process instances from given path of nJAMS instance due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

	Exit
}
