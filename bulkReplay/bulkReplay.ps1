<#
.SYNOPSIS
    Execute Replay based on configuration in properties file.

.DESCRIPTION

.PARAMETER propertyFile
    Full path to replay properties file, e.g. "./replay.properties".

.PARAMETER query
    Switch to query for results.

.PARAMETER replay
    Switch to replay results that have been queried before.
    
.PARAMETER test
    Switch to query for results and test replaying. Does not execute a replay.

.EXAMPLE

.LINK
    https://github.com/integrationmatters/njams-toolbox

.NOTES
    Version:    1.1.1
    Copyright:  (c) Integration Matters
    Date:       June 2025
#>

param (
    [string]$propertyFile = "./replay.properties",
    [switch]$query,
    [switch]$replay,
    [switch]$test
)

# Trim replay property filename:
$propertyFile = ($propertyFile -replace '[\\/]?[\\/]$')

# Declare variables for usage in Java command
$jarFile = "njams-replay-plugin-commandline-5.2.0.jar"

# This function reads control file 'replay.properties' from source path and
# returns hash table of properties:
function fnReadControlFile($ctrlFile){

    try {

        if (Test-Path -LiteralPath $ctrlFile) {

            $contentFile = Get-Content $ctrlFile

            if($contentFile.length -ne 0) {

                ($contentFile) | foreach-object -begin {$h=@{}} -process { $k = [regex]::split($_,'='); if(($k[0].CompareTo("") -ne 0) -and ($k[0].StartsWith("[") -ne $True) -and ($k[0].StartsWith("#") -ne $True)) { $h.Add($k[0], $k[1]) } }

                write-host "Control properties file has been read."
                return $h
            }
            else {
                write-host "Control file is empty. Please make sure $ctrlFile exists."
                return 0
            }
        }
        else {
            write-host "Control file not found. Please make sure $ctrlFile exists."
            return 0
        }
    }
    catch {
        write-host "Error reading control file '$ctrlFile'. Please make sure control file is valid and resides in current path. `n$ErrorMessage"
        return 0
    }
}

# Check Java version:
try {

    # Try to check Java version:
    $result = java -version

    if ($result) {

        write-host "Java is not available, please make sure Java is installed correctly." -ForegroundColor Yellow

        Exit
    }
}
catch {
	write-host "Unable to find Java on this machine:" -ForegroundColor Red
    write-host "$_.Exception.Message"

	Exit
}

# Read control file:
$ctrl = fnReadControlFile($propertyFile)

# Execute query command:
if ($ctrl) {

    try {

        # This Java command...
        if($env:JAVA_HOME)
        {
            # If applicable, add truststore/pw for https connection to nJAMS instance:
            if ($ctrl.Get_Item("trustStore") -and
                $ctrl.Get_item("trustStorePassword")) {

                if ($ctrl.Get_Item("trustStore").Trim('"') -and 
                    $ctrl.Get_Item("trustStorePassword").Trim('"')) {
                        $javaTrustStore = $ctrl.Get_Item("trustStore")
                        $javaTrustStorePassword = $ctrl.Get_Item("trustStorePassword")
                            $argList = @("-Djavax.net.ssl.trustStore=./wildcard.integrationmatters.com.jks", "-Djavax.net.ssl.trustStorePassword=njamspw", "-jar", $jarFile)
                }
                else {
                    $argList = @("-Djavax.net.ssl.trustStore=$javaTrustStore", "-Djavax.net.ssl.trustStorePassword=$javaTrustStorePassword", "-jar", $jarFile)
                }
            }
            else {
                $argList = @("-jar", $jarFile)
            }

            # Add login args to statement:
            if ($ctrl.Get_Item("user") -and 
                $ctrl.Get_Item("password") -and 
                $ctrl.Get_Item("instanceURL")) {

                if ($ctrl.Get_Item("user").Trim('"') -and 
                    $ctrl.Get_Item("password").Trim('"') -and 
                    $ctrl.Get_Item("instanceURL").Trim('"')) {
                        $njamsUser = $ctrl.Get_Item("user")
                        $njamsPassword = $ctrl.Get_Item("password")
                        $njamsInstanceURL = $ctrl.Get_Item("instanceURL")
                }
                else {
                    write-host "No nJAMS instance or credentials specified."
                    Exit
                }
            }

            # Add query result directory args to statement:
            if ($ctrl.Get_Item("queryResultDir")) {
                if ($ctrl.Get_Item("queryResultDir").Trim('"')) {
                    $queryResultDir = $ctrl.Get_Item("queryResultDir")
                }
                else {
                    $queryResultDir += "-qm", "./"
                }
            }

            # Execute query command:
            if ($query -or $test) {

                $argQueryCmdList = $argList

                $argQueryCmdList += "-i", $njamsUser, $njamsPassword, $njamsInstanceURL

                $argQueryCmdList += "-qm", $queryResultDir

                # Add time args to statement:
                if ($ctrl.Get_Item("queryTimeFrom")) {
                    if ($ctrl.Get_Item("queryTimeFrom").Trim('"')) {

                        $argQueryCmdList += "-q", "-sf", $ctrl.Get_Item("queryTimeFrom")

                        if ($ctrl.Get_Item("queryTimeTo")) {
                            if ($ctrl.Get_Item("queryTimeTo").Trim('"')) {
                                $argQueryCmdList += "-st", $ctrl.Get_Item("queryTimeTo")
                            }
                        }
                    }
                }

                # Add timezone args to statement:
                if ($ctrl.Get_Item("queryTimezone")) {
                    if ($ctrl.Get_Item("queryTimezone").Trim('"')) {
                        $argQueryCmdList += "-tz", $ctrl.Get_Item("queryTimezone")
                    }
                }

                # Add domain object path args to statement:
                if ($ctrl.Get_Item("queryDomainObjectPath")) {
                    if ($ctrl.Get_Item("queryDomainObjectPath").Trim('"')) {
                        $argQueryCmdList += "-sp", "DO", $ctrl.Get_Item("queryDomainObjectPath")
                    }
                }

                # Add business object args to statement:
                if ($ctrl.Get_Item("queryBusinessObject")) {
                    if ($ctrl.Get_Item("queryBusinessObject").Trim('"')) {
                        $argQueryCmdList += "-sp", "BO", $ctrl.Get_Item("queryBusinessObject")
                    }
                }

                # Add business Service args to statement:
                if ($ctrl.Get_Item("queryBusinessService")) {
                    if ($ctrl.Get_Item("queryBusinessService").Trim('"')) {
                        $argQueryCmdList += "-sp", "BS", $ctrl.Get_Item("queryBusinessService")
                    }
                }

                # Add status args to statement:
                if ($ctrl.Get_Item("queryStatus")) {
                    if ($ctrl.Get_Item("queryStatus").Trim('"')) {
                        $argQueryCmdList += "-sst", $ctrl.Get_Item("queryStatus")
                    }
                }

                # Add query string args to statement:
                if ($ctrl.Get_Item("queryString")) {
                    if ($ctrl.Get_Item("queryString").Trim('"')) {
                        $argQueryCmdList += "-q", $ctrl.Get_Item("queryString")
                    }
                }

                # Add query string args to statement:
                if ($ctrl.Get_Item("queryOutput")) {
                    if ($ctrl.Get_Item("queryOutput").Trim('"').ToLower() -eq 'true') {
                        $argQueryCmdList += "-qd", $ctrl.Get_Item("queryOutput")
                    }
                }

                # Empty result folder before starting Replay?
                if ($ctrl.Get_Item("queryEmptyResultDir")) {
                    if ($ctrl.Get_Item("queryEmptyResultDir").Trim('"').ToLower() -eq 'true') {
                        # Delete files from result directory:
                        remove-item $($ctrl.Get_Item("queryResultDir").Trim('"') + '/*.*')
                    }
                }

                # Start query command:
                $params = @{
                    FilePath = "java"
                    ArgumentList = $argQueryCmdList
                    RedirectStandardError = "./QueryCmdError.log"
                    PassThru = $true
                    NoNewWindow = $true
                    Wait = $true
                }

                $result = Start-Process @params

                # If Java command line returns (error) message, exit script:
                if ($result.ExitCode -ne 0) {
                    
                    write-host "Replay command fails due to:" -ForegroundColor Red
                    write-host $result

                    Exit
                }
            }

            # Execute replay command:
            if ($replay -or $test) {
                $argReplayCmdList = $argList
                $argReplayCmdList += "-i", $njamsUser, $njamsPassword, $njamsInstanceURL
                $argReplayCmdList += "-rf", $queryResultDir
                $argReplayCmdList += "-rr", "ReplayCmdResult.log"
                if ($test) {
                    $argReplayCmdList += "-t"
                }

                $params = @{
                    FilePath = "java"
                    ArgumentList = $argReplayCmdList
                    RedirectStandardError = "./ReplayCmdError.log"
                    PassThru = $true
                    NoNewWindow = $true
                    Wait = $true
                }

                $result = Start-Process @params

                # If Java command line returns (error) message, exit script:
                if ($result.ExitCode -ne 0) {
                    
                    write-host "Replay command fails due to:" -ForegroundColor Red
                    write-host $result

                    Exit
                }
            }
        }
        else {
            write-host "JAVA_HOME not set."
        }

        write-host "Replay command executed successfully."
    }
    catch {
        write-host "Script fails due to:" -ForegroundColor Red
        write-host "$_.Exception.Message"

        Exit
    }
}

