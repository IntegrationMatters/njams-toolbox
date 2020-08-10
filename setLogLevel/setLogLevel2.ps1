<#
.SYNOPSIS
    Set log level for processes of a given domain object path.
.DESCRIPTION
	This script changes the log level of processes related to a specified domain object path including its sub elements.
	The log level can be set to INFO, SUCCESS, WARNING, or ERROR.
	The script requires to enter the URL of your nJAMS Server instance, including username and password, the domain object path that contains the processes you want to change log level for, and the new log level. 
	The script can be executed on any Windows, Linux, or Mac machine within the same network of the machine, where nJAMS Server is running.
	Characteristics:
	- allows to change log level for a bunch of processes
	- allows RegEx in filter criteria to limit processes of a domain object path
	- parameter "list" allows to only display the list of selected processes for which the log level should be changed without changing the log level.
	- supports nJAMS Server instances 4.4, 5.0, and 5.1 using HTTP or TLS/HTTPS.
	- script runs on Windows, Linux, and macOS using Powershell Core 7 or Windows Powershell 5
	- output can be formatted individually by common Powershell format commands
	
	Please note:
	Make sure the corresponding nJAMS Client for the domain object path is running and able to receive commands to change the log level.

.PARAMETER instance
    Enter the nJAMS instance URL, e.g. "http://localhost:8080/njams". This parameter is mandatory.

.PARAMETER username
    Enter username of the nJAMS instance account. Default is "admin".

.PARAMETER password
    Enter password of the nJAMS instance account. Default is "admin".

.PARAMETER domainObjectPath
    Specifies the domain object path, e.g. ">domain>deployment>engine>". This path is searched for domain objects for which the log level should be changed. This parameter is mandatory. 

.PARAMETER logLevel
    Specifies the 'logLevel' for a domain object. Must contain one of these values: "INFO", "SUCCESS", "WARNING", or "ERROR". This parameter is mandatory.

.PARAMETER filter
    Filters domain objects by name of the specified domain object path. Use RegEx for the filter criterion. This parameter is optional.
    
.PARAMETER list
    When this parameter is specified, the log level will NOT be applied, but only a list of matching domain objects will be returned. This is useful for checking the filter criterion. This parameter is optional.

.PARAMETER check
    When this parameter is specified, the script virtually simulates setting the log level. It determines the domain objects and checks the coresponding nJAMS Client for availability. This parameter is optional.
    
.EXAMPLE
    ./setLogLevel.ps1 -instance "http://localhost:8080/njams" -path ">prod>finance>invoicing>" -filter "Starter.*" -loglevel "ERROR"
    Sets log level to "ERROR" for domain objects whose names begin with "Starter" of domain object path ">prod>finance>invoicing>".

.EXAMPLE
    ./setLogLevel.ps1 -instance "http://localhost:8080/njams" -path ">test>" -filter ".*TargetSAP.*" -list
    Lists matching domain objects, while checking communication to nJAMS Client(s). Log level settings remain unchanged. 
	
.LINK
    https://www.integrationmatters.com/

.NOTES
    Version:    1.0.0
    Copyright:  (c) Integration Matters
    Author:     Stephan Holters
    Date:       August 2020
#>

param (
    [Parameter(Mandatory=$true)][string]$instance,
    [Parameter(Mandatory=$true)][string]$username = "admin",
	[Parameter(Mandatory=$true)][string]$password = "admin",
	[Parameter(Mandatory=$true)][string][Alias("path")]$domainObjectPath,
	[string][Alias("filter")]$filterProcess = ".*",
	[Parameter(Mandatory=$true)][string][ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")][Alias("logLevel")]$domainObjectLogLevel, # INFO | SUCCESS | WARNING | ERROR
    [switch]$list
)

# -------------------------------------------------------
# Declare global variables:
# nJAMS instance:
<#
$njamsInstanceUrl = "http://10.189.0.137:8080/njams"
$njamsUser = "admin"
$njamsPW = "admin"
$domainObjectPath = "%3Edomain%3Edeployment%3ESupport%3E"
$domainObjectLogLevel = "INFO" # INFO | SUCCESS | WARNING | ERROR
#>

# Change policy to trust all certificates, just in case you are using TLS/HTTPS:
# Use -SkipCertificateCheck in "Invoke-RestMethod" instead, when you are on PScore.
# For Windows Powershell 5 use the following:
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

# Recursively loop each element and set log level:
function fnSetLogLevel ([string]$doId, [string]$doType) {

    # If id is 0, just send object type, otherwise send id and object type:
    if($doId -eq "0") {
        $myRequestBody = '{ "objectType": "' + $doType + '" }'
    }
    else {
        $myRequestBody = '{ "id": "' + $doId + '", "objectType": "' + $doType + '" }'
    }

    # Get elements of domain object:
    if ($PSVersionTable.PSEdition -eq "Core") {
        $domainObjects = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -Body $myRequestBody -uri "$instance/api/mainobjecttree" -WebSession $mySession
    }
    else {
        $domainObjects = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -Body $myRequestBody -uri "$instance/api/mainobjecttree" -WebSession $mySession
    }

    # Determine request body to set log level:
    $myLogLevel = '{ "logLevel": "' + $domainObjectLogLevel + '" }'
    # Header for domainobject/refresh request that acceppts application/json:
    $myHeaderAcceptJson = @{
        "Authorization" = "Basic"+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('"$username:$password"')) 
        "Accept" = "application/json"
    }
    
    # Walk through domain object hierarchy starting from object of given id and type:
    Foreach ($do in $domainObjects)
    {
        # If domain object has no children items:
        if ([string]$do.hasChildren -eq "False") {
            # If domain object is of type "process" and matches filter:
            if ([string]$do.type -like "*process*" -and $do.name -match $filterProcess) {

                if ($list) {
                    if ($PSVersionTable.PSEdition -eq "Core") {
                        $processDomainObject = Invoke-RestMethod -Method GET -Header $myHeaderAcceptJson -ContentType "application/json" -SkipCertificateCheck -uri "$instance/api/domainobject/refresh/$($do.id)" -WebSession $mySession
                    }
                    else {
                        $processDomainObject = Invoke-RestMethod -Method GET -Header $myHeaderAcceptJson -ContentType "application/json" -uri "$instance/api/domainobject/refresh/$($do.id)" -WebSession $mySession
                    }

                    $outputDO = New-Object PSObject -Property @{
                        Id                  = $($do.id)
                        Name                = $($do.name)
                        'LogLevel'          = $($processDomainObject.logLevel)
                        Path                = $($do.path)
                    }

                    write-output $outputDO
                }
                else {
                    Write-Output "Set LogLevel=$domainObjectLogLevel for domain object: $($do.id), $($do.name)... "
                    if ($PSVersionTable.PSEdition -eq "Core") {
                        Invoke-RestMethod -Method PUT -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -Body $myLogLevel -uri "$instance/api/domainobject/$($do.id)" -WebSession $mySession
                    }
                    else {
                        Invoke-RestMethod -Method PUT -Header $myHeader -ContentType "application/json" -Body $myLogLevel -uri "$instance/api/domainobject/$($do.id)" -WebSession $mySession
                    }
                }
            }
        }
        # If there are children items available:
        else {
            # Inspect next level for domain objects to change log level for:
            fnSetLogLevel "$($do.id)" "$($do.objectType)"
        }
    }
}

# General header for requests:
$myHeader = @{
    "Authorization" = "Basic"+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('"$username:$password"')) 
}

# (1) Login as admin:
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

# (2) Get domaqin object id of given domain object path:
$myRequestBody = '{ "objectType": "DO", "objectPath": "' + $domainObjectPath + '" }'

try {
    if ($PSVersionTable.PSEdition -eq "Core") {
		$domainObject = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -Body $myRequestBody -uri "$instance/api/mainobject" -WebSession $mySession
	}
	else {
		$domainObject = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -Body $myRequestBody -uri "$instance/api/mainobject" -WebSession $mySession
    }
}
catch {
	write-host "Unable to retrieve domain object id from given path of nJAMS instance due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

	Exit
}

# (3) Set log level of all processes and sub processes of secified domain object path:
try {
    # Recursively set log level of processes related to domain object path:
    if ($list) {
        write-output "List of matching domain objects, while checking communication to nJAMS Client(s). Log level settings remain unchanged:"
    }
    else {
        write-host "You are going to change the log level of all processes of path '$domainObjectPath' and all of its sub elements." -ForegroundColor Yellow
        $input = read-host "Do you want to proceed? [Y] Yes  [N] No"
        if ($input.ToLower() -ne "y" -and $input.ToLower() -ne "yes") {
            write-host "No change of log level."

            Exit
        }
    }

    fnSetLogLevel "$($domainObject.id)" "DO"

    write-output "Finished." 
}
catch {
    write-host "Unable to set log level for processes of domain object path due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

    Exit
}
