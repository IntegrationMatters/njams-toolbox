# This script sets LogLevel to all sub elements of a domain object path
# (c) Integration Matters 2020

param (
    [string]$instance = "http://localhost:8080/njams",
    [string]$username = "admin",
	[string]$password = "admin",
    [Parameter(Mandatory=$true)] [string][Alias("path")]$domainObjectPath,
	[Parameter(Mandatory=$true)] [string][Alias("loglevel")]$domainObjectLogLevel # INFO | SUCCESS | WARNING | ERROR
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
write-output "Login..."
$myBody = '{ "username": "' + $username + '" , ' + '"password": "' + $password + '" }'
$mySession = $null #empty variable session
Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -Body $myBody -uri "$instance/api/usermanagement/authentication" -SessionVariable mySession

# (2) Get list of sub elements of given domain object path:
Write-Output "Get list of domain objects..."
$domainObjects = Invoke-RestMethod -Method GET -Header $myHeader -ContentType "application/json" -uri "$instance/api/domainobject/path/$domainObjectPath" -WebSession $mySession

Write-output $domainObjects

# (3) Loop each sub element and set LogLevel:
$myLogLevel = '{ "logLevel": "' + $domainObjectLogLevel + '" }'
foreach ($doId in ($domainObjects | Where-Object { $_.name -like "*" }).id){
	Write-Output "Set LogLevel=$domainObjectLogLevel for domain object Id: $doId"
	Invoke-RestMethod -Method PUT -Header $myHeader -ContentType "application/json" -Body $myLogLevel -uri "$instance/api/domainobject/$doId" -WebSession $mySession
}
