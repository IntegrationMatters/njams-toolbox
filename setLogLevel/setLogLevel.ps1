# This script sets LogLevel to all sub elements of a domain object path
# (c) Integration Matters 2020

param (
    [Parameter(Mandatory=$true)][string]$instance,
    [Parameter(Mandatory=$true)][string]$username = "admin",
	[Parameter(Mandatory=$true)][string]$password = "admin",
	[Parameter(Mandatory=$true)][string][Alias("path")]$domainObjectPath,
	[string][Alias("filter")]$filterProcess = ".*",
	[Parameter(Mandatory=$true)][string][ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")][Alias("loglevel")]$domainObjectLogLevel, # INFO | SUCCESS | WARNING | ERROR
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

# General header for request:
$myHeader = @{"Authorization" = "Basic"+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('"$username:$password"'))}

# (1) Login as admin:
$myBody = '{ "username": "' + $username + '" , ' + '"password": "' + $password + '" }'
$mySession = $null #empty variable session
try {
	$userId = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -Body $myBody -uri "$instance/api/usermanagement/authentication" -SessionVariable mySession
}
catch {
	write-host "Unable to login into nJAMS instance due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

	Exit
}

# (2) Get list of sub elements of given domain object path:
try {
	$domainObjects = Invoke-RestMethod -Method GET -Header $myHeader -ContentType "application/json" -uri "$instance/api/domainobject/path/$domainObjectPath" -WebSession $mySession
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
				Invoke-RestMethod -Method PUT -Header $myHeader -ContentType "application/json" -Body $myLogLevel -uri "$instance/api/domainobject/$($do.id)" -WebSession $mySession
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
