<#
.SYNOPSIS
    Set log level for processes of a given domain object path.
.DESCRIPTION
	This script changes the log level of processes related to a specified domain object path.
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
    Determines the path of a domain object for whose processes a new log level should be applied, for example ">domain>deployment>engine>". This parameter is mandatory. 

.PARAMETER logLevel
    Specifies the 'logLevel' for a domain object. Must contain one of these values: "INFO", "SUCCESS", "WARNING", or "ERROR". This parameter is mandatory.

.PARAMETER filter
    Filters processes by name of the given domain object. Use RegEx to limit processes. This parameter is optional.
    
.PARAMETER list
    When this parameter is specified, the log level will NOT be applied, but only a list of matching processes will be returned. This is useful for checking whether the processes  are correct. This parameter is optional.
    
.EXAMPLE
    ./setLogLevel.ps1 -instance "http://localhost:8080/njams" -path ">prod>finance>invoicing>" -filter "Starter.*" -loglevel "ERROR"
    Sets log level to "ERROR" for all processes whose names start with "Starter" of domain object ">prod>finance>invoicing>".

.EXAMPLE
    ./setLogLevel.ps1 -instance "http://localhost:8080/njams" -path ">prod>finance>invoicing>" -loglevel "SUCCESS" -list
    Lists all processes of domain object ">prod>finance>invoicing>" without changing log level.
	
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

# General header for request:
$myHeader = @{"Authorization" = "Basic"+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('"$username:$password"'))}

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

# (2) Get list of sub elements of given domain object path:
try {
    if ($PSVersionTable.PSEdition -eq "Core") {
		$domainObjects = Invoke-RestMethod -Method GET -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -uri "$instance/api/domainobject/path/$domainObjectPath" -WebSession $mySession
	}
	else {
		$domainObjects = Invoke-RestMethod -Method GET -Header $myHeader -ContentType "application/json" -uri "$instance/api/domainobject/path/$domainObjectPath" -WebSession $mySession
	}
}
catch {
	write-host "Unable to retrieve domain objects from nJAMS instance due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

	Exit
}

# (3) Loop each sub element and set LogLevel:
try {
	if (($domainObjects).Count -ne 0) {
		$counter = 0

		if ($list) {
			write-output "Domain objects will be just listed, LogLevel settings will remain unchanged:"
		}

		$myLogLevel = '{ "logLevel": "' + $domainObjectLogLevel + '" }'

		foreach ($do in $domainObjects | Where-Object { $_.name -match $filterProcess -and $_.type -like "*process*"}){
			$counter++
			if ($list) {
				write-output $do
			}
			else {
				Write-Output "Set LogLevel=$domainObjectLogLevel for domain object: $($do.id), $($do.name)"
				if ($PSVersionTable.PSEdition -eq "Core") {
					Invoke-RestMethod -Method PUT -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -Body $myLogLevel -uri "$instance/api/domainobject/$($do.id)" -WebSession $mySession
				}
				else {
					Invoke-RestMethod -Method PUT -Header $myHeader -ContentType "application/json" -Body $myLogLevel -uri "$instance/api/domainobject/$($do.id)" -WebSession $mySession
				}
			}
		}
		if ($counter -eq 0) {
			write-output "No domain objects of type 'process' found."
		}
	}
	else {
		write-output "No domain objects found."
	}
}
catch {
	write-host "Unable to set LogLevel due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

	Exit
}
