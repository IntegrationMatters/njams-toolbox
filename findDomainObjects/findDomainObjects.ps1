<#
.SYNOPSIS
    Find domain objects of given nJAMS instance. 
.DESCRIPTION
    This script browses the domain objects of an nJAMS Server instance. 
    You can enter various filter criteria such as settings for retention or loglevel, as well as properties like nJAMS Client version number. Especially in large nJAMS instances with thousands of domain objects 'findDomainObjects' helps you to detect misconfigurations of domain objects and outdated versions of nJAMS Clients.
    If you omit any filter criteria, the script provides a list of all domain objects.
    The script outputs a list of domains objects that can be formatted by common ps format commands.
    Characteristics:
    - find domain objects of an nJAMS instance
	- filter list of domain objects by common settings such as 'retention', 'stripOnSuccess', or by process and client properties like 'logLevel', 'exclude', 'logMode', 'version' of nJAMS Clients, etc.
	- allows RegEx in filter criteria for more precise hits
	- supports nJAMS Server instances 4.4, 5.0, and 5.1 using HTTP or TLS/HTTPS.
	- script runs on Windows, Linux, and MacOS using Powershell Core 7 or Windows Powershell 5
    - output can be formatted individually by common Powershell format commands

.PARAMETER instance
    Enter the nJAMS instance URL, e.g. "http://localhost:8080/njams". This parameter is mandatory.

.PARAMETER username
    Enter username of the nJAMS instance account. Default is "admin".

.PARAMETER password
    Enter password of the nJAMS instance account. Default is "admin".

.PARAMETER name
    Find domain objects of a particular name. Use standard wildcards. Default is any value.

.PARAMETER parentId
    Find domain objects of a parent domain object id. Enter positive integer value. Default is root Id (0).

.PARAMETER category
    Find domain objects of monitored integration platform, e.g. "BW, "BW6", "MULE4EE", etc. Default is any value.
    
.PARAMETER stripOnSuccess
    Find domain objects, where setting 'stripOnSucces' is "true" or "false". Default is any value.
    
.PARAMETER retention
    Find domain objects of a particular 'retention' setting, e.g. "7". Use RegEx to limit retention, e.g. "[1-3][0-9]" finds any retention between 10 and 39 days. Default is any value.
    
.PARAMETER logLevel
    Find domain objects, where setting 'logLevel' is "INFO", "SUCCESS", "WARNING", or "ERROR". Default is any value.
    
.PARAMETER exclude
    Find domain objects, where setting 'exclude' is is "true" or "false". Default is any value.
    
.PARAMETER versionNumber
    Find domain objects of a particular nJAMS Client version. User RegEx to limit version, e.g. "4.[0-1].*" finds any version of "4.0" and "4.1". Default is any value.
    
.PARAMETER sdkVersion
    Find domain objects of a particular SDK version of an nJAMS Client. Use RegEx to limit SDK version, e.g. "4.*" finds any SDK version of "4". Default is any value.

.PARAMETER machineName
    Find domain objects of a particular machine. Use standard wildcards. Default is any value.

.PARAMETER logMode
    Find domain objects, where setting logMode' is "COMPLETE", EXCLUSIVE", or "NONE". Default is any value.


.EXAMPLE
    ./findDomainObjects.ps1 -instance "http://localhost:8080/njams" -username "admin" -password "admin"
    Finds all domain objects of an instance by using specified credentials.
    You can automatically format the list for tabular output using format command:
    ./findDomainObjects.ps1 -instance "http://localhost:8080/njams" -username "admin" -password "admin" | format-table

.EXAMPLE
    ./findDomainObjects.ps1 -instance "http://localhost:8080/njams" -logLevel "ERROR"
    Finds all domain objects, where logLevel=ERROR by using default credentials (admin/admin).

.EXAMPLE
    ./findDomainObjects.ps1 -instance "http://localhost:8080/njams" -version "4.1.*"
    Finds all domain objects, where nJAMS Client version starts with 4.1.
    Use regular expression to match version numbers, e.g. "4.[1-2].*".

.EXAMPLE
    ./findDomainObjects.ps1 -instance "http://localhost:8080/njams" -name "*C1*"
    Finds all domain objects, where name contains "C1".
    You can use wildcards '*', '?' to match domain object names.

.LINK
    https://www.integrationmatters.com/

.NOTES
    Version:    1.0.0
    Copyright:  (c) Integration Matters
    Author:     Stephan Holters
    Date:       July 2020
#>

param (
    [string]$instance = "http://localhost:8080/njams",
    [string]$username = "admin",
    [string]$password = "admin",
    # filter criteria for do type "Client":
    [string][Alias("version")]$versionNumber = ".*",
    [string][Alias("sdk")]$sdkVersion = ".*",
    [string][ValidateSet("COMPLETE", "EXCLUSIVE", "NONE")]$logMode = "*",
    [string][Alias("machine")]$machineName = "*",
    # filter criteria for domain object type "Process":
    [string][ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]$logLevel = "*",
    [string][ValidateSet("True", "False")]$exclude = "*",
    # filter criteria for any domain object type:
    [string]$name = "*",
    [string]$category = "*",
    [string][ValidateSet("True", "False")][Alias("strip")]$stripOnSuccess = "*",
    [string]$retention = ".*",
    [int]$parentId = 0
    )

# Determine for what kind of domain object type the user is searching:
# all: print all domain objects types
# client: print domain objects of type "Client"
# process: print domain objects of type "Process"
$findClientDomainObjects = $false
$findProcessDomainObjects = $false
$findAllDomainObjects = $false
if ($PSBoundParameters.ContainsKey('versionNumber') -eq $True -or
    $PSBoundParameters.ContainsKey('sdkVersion') -eq $True -or
    $PSBoundParameters.ContainsKey('machineName') -eq $True -or
    $PSBoundParameters.ContainsKey('logMode') -eq $True) {

        $findClientDomainObjects = $True
    }
if ($PSBoundParameters.ContainsKey('logLevel') -eq $True -or 
    $PSBoundParameters.ContainsKey('exclude') -eq $True) {

        $findProcessDomainObjects = $True
}
if ($PSBoundParameters.ContainsKey('name') -eq $True -or
    $PSBoundParameters.ContainsKey('category') -eq $True -or
    $PSBoundParameters.ContainsKey('stripOnSuccess') -eq $True -or
    $PSBoundParameters.ContainsKey('retention') -eq $True) {

        $findAllDomainObjects = $True
}
if ($PSBoundParameters.ContainsKey('name') -eq $false -and
    $PSBoundParameters.ContainsKey('category') -eq $false -and
    $PSBoundParameters.ContainsKey('stripOnSuccess') -eq $false -and
    $PSBoundParameters.ContainsKey('retention') -eq $false -and
    $PSBoundParameters.ContainsKey('versionNumber') -eq $false -and
    $PSBoundParameters.ContainsKey('sdkVersion') -eq $false -and
    $PSBoundParameters.ContainsKey('machineName') -eq $false -and
    $PSBoundParameters.ContainsKey('logMode') -eq $false -and
    $PSBoundParameters.ContainsKey('logLevel') -eq $false -and
    $PSBoundParameters.ContainsKey('exclude') -eq $false) {
        
        $findAllDomainObjects = $True
}

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

# Loop each elements and compare log level:
function fnBrowseDomainObjects ([string]$doId, [string]$doType) {

        # If id is 0, just send object type, otherwise send id and object type:
    if($doId -eq "0") {
        $myRequestBody = '{ "objectType": "' + $doType + '" }'
    }
    else {
        $myRequestBody = '{ "id": "' + $doId + '", "objectType": "' + $doType + '" }'
    }

    if ($PSVersionTable.PSEdition -eq "Core") {
        $domainObjects = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -Body $myRequestBody -uri "$instance/api/mainobjecttree" -WebSession $mySession
    }
    else {
        $domainObjects = Invoke-RestMethod -Method POST -Header $myHeader -ContentType "application/json" -Body $myRequestBody -uri "$instance/api/mainobjecttree" -WebSession $mySession
    }
    # Walk through domain object hierarchy starting from object of given id and type:
    Foreach ($do in $domainObjects)
    {
        # If domain object has no children items:
        if ([string]$do.hasChildren -eq "False") {
            # If domain object is of type "process":
            if ([string]$do.type -like "*process*") {
                # If user wants to find process or all objects:
                if ($findProcessDomainObjects -eq $True -or $findAllDomainObjects -eq $True) {
                    if ($PSVersionTable.PSEdition -eq "Core") {
                        $processDomainObject = Invoke-RestMethod -Method GET -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -uri "$instance/api/domainobject/extended/$($do.Id)" -WebSession $mySession
                    }
                    else {
                        $processDomainObject = Invoke-RestMethod -Method GET -Header $myHeader -ContentType "application/json" -uri "$instance/api/domainobject/extended/$($do.Id)" -WebSession $mySession
                    }
                    if ([string]$processDomainObject.logLevel -like $logLevel -and
                        [string]$processDomainObject.exclude -like $exclude -and 
                        [string]$processDomainObject.name -like $name -and 
                        [string]$processDomainObject.category -like $category -and 
                        [string]$processDomainObject.stripOnSuccess -like $stripOnSuccess -and 
                        [string]$processDomainObject.retention -match $retention) {
                            # Write-Output "Category: $($processDomainObject.category), LogLevel: $($processDomainObject.logLevel), Exclude: $($processDomainObject.exclude), StripOnSuccess: $($processDomainObject.stripOnSuccess), Retention: $($processDomainObject.retention), DO: $($do.id) $($do.path)"
                            $outputDO = New-Object PSObject -Property @{
                                Version             = ""
                                'SDK Version'       = ""
                                'LogMode'           = ""
                                'Machine Name'      = ""
                                Name                = $($processDomainObject.name)
                                Category            = $($processDomainObject.category)
                                'LogLevel'          = $($processDomainObject.logLevel)
                                Exclude             = $($processDomainObject.exclude)
                                'Strip On Success'  = $($processDomainObject.stripOnSuccess)
                                Retention           = $($processDomainObject.retention)
                                Id                  = $($do.id)
                                Path                = $($do.path)
                            }
                            write-output $outputDO
                    }
                }
            }
        }
        # If there are children items available:
        else {
            # If domain object is of type "client":
            If ([string]$do.client -eq "True") {
                # If the user wants to find client or all objects:
                if ($findClientDomainObjects -eq $true -or $findAllDomainObjects -eq $true) {
                    if ($PSVersionTable.PSEdition -eq "Core") {
                        $clientDomainObject = Invoke-RestMethod -Method GET -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -uri "$instance/api/domainobject/extended/$($do.Id)" -WebSession $mySession
                    }
                    else {
                        $clientDomainObject = Invoke-RestMethod -Method GET -Header $myHeader -ContentType "application/json" -uri "$instance/api/domainobject/extended/$($do.Id)" -WebSession $mySession
                    }
                    if ([string]$clientDomainObject.versionNumber -match $versionNumber -and 
                        [string]$clientDomainObject.sdkVersion -match $sdkVersion -and 
                        [string]$clientDomainObject.machineName -like $machineName -and 
                        [string]$clientDomainObject.logMode -like $logMode -and 
                        [string]$clientDomainObject.name -like $name -and
                        [string]$clientDomainObject.category -like $category -and
                        [string]$clientDomainObject.stripOnSuccess -like $stripOnSuccess -and 
                        [string]$clientDomainObject.retention -match $retention) {
                            # Write-Output "Category: $($clientDomainObject.category), Version: $($clientDomainObject.versionNumber), SDK: $($clientDomainObject.sdkVersion), logMode: $($clientDomainObject.logMode), Machine: $($clientDomainObject.machineName), StripOnSuccess: $($clientDomainObject.stripOnSuccess), Retention: $($clientDomainObject.retention), DO: $($clientDomainObject.id) $($clientDomainObject.objectPath)"

                            $outputDO = New-Object PSObject -Property @{
                                Version             = $($clientDomainObject.versionNumber)
                                'SDK Version'       = $($clientDomainObject.sdkVersion)
                                'LogMode'           = $($clientDomainObject.logMode)
                                'Machine Name'      = $($clientDomainObject.machineName)
                                Name                = $($clientDomainObject.name)
                                Category            = $($clientDomainObject.category)
                                'LogLevel'          = ""
                                Exclude             = ""
                                'Strip On Success'  = $($clientDomainObject.stripOnSuccess)
                                Retention           = $($clientDomainObject.retention)
                                Id                  = $($clientDomainObject.id)
                                Path                = $($clientDomainObject.objectPath)
                            }
                            write-output $outputDO
                    }
                }
            }
            else {
                # If user wants to find all objects:
                if ($findAllDomainObjects -eq $true) {
                    if ($PSVersionTable.PSEdition -eq "Core") {
                        $anyDomainObject = Invoke-RestMethod -Method GET -Header $myHeader -ContentType "application/json" -SkipCertificateCheck -uri "$instance/api/domainobject/extended/$($do.Id)" -WebSession $mySession
                    }
                    else {
                        $anyDomainObject = Invoke-RestMethod -Method GET -Header $myHeader -ContentType "application/json" -uri "$instance/api/domainobject/extended/$($do.Id)" -WebSession $mySession
                    }
                    if([string]$anyDomainObject.name -like $name -and
                        [string]$anyDomainObject.category -like $category -and 
                        [string]$anyDomainObject.stripOnSuccess -like $stripOnSuccess -and 
                        [string]$anyDomainObject.retention -match $retention) {
                            # Write-Output "Category: $($anyDomainObject.category), StripOnSuccess: $($anyDomainObject.stripOnSuccess), Retention: $($anyDomainObject.retention), DO: $($anyDomainObject.id) $($anyDomainObject.objectPath)"
                            $outputDO = New-Object PSObject -Property @{
                                Version             = ""
                                'SDK Version'       = ""
                                'LogMode'           = ""
                                'Machine Name'      = ""
                                Name                = $($anyDomainObject.name)
                                Category            = $($anyDomainObject.category)
                                'LogLevel'          = ""
                                Exclude             = ""
                                'Strip On Success'  = $($anyDomainObject.stripOnSuccess)
                                Retention           = $($anyDomainObject.retention)
                                Id                  = $($anyDomainObject.id)
                                Path                = $($anyDomainObject.objectPath)
                            }
                            write-output $outputDO
                    }
                }
            }

            fnBrowseDomainObjects "$($do.id)" "$($do.objectType)"
        }
    }
}

# General header for request:
$myHeader = @{"Authorization" = "Basic"+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('"$username:$password"'))}

write-host "Browsing domain objects of nJAMS instance: $instance"

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

# (2) Find domain objects starting from root:
# Initialize domain object id / type:
$startDoId = $parentId
$startDoType = "DO"
try {
    # Browse domain objects:
    fnBrowseDomainObjects "$startDoId" "$startDoType"

    write-host "Finished." 
}
catch {
    write-host "Unable to retrieve domain objects from nJAMS instance due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

    Exit
}
