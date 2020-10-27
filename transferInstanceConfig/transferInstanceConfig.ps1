<#
.SYNOPSIS
    Transfers configuration from source nJAMS instance to target nJAMS instance. 
.DESCRIPTION
    This script transfers the configuration settings from a given source nJAMS instance to a given target nJAMS instance.
    This tool might be useful, if you want to create a new nJAMS instance based on the same settings of an existing nJAMS instance.
    You can specify individual configurations to transfer.
    The following configurations can be transfered:
    * config - basic settings of an nJAMS Server instance such as name of instance, search options, global retention settings, etc.
    * ldap - settings of a LDAP configuration
    * dataProvider - settings of Data Providers including JMS and JNDI configurations
    * mail - settings of a smtp server
    * argos - settings of Argos configuration
    * user - user accounts and roles including assignments
    * objectPrivilege - domain object permissions for roles
    * systemPrivilege - system privileges for roles
    
    If you do not specify a particular configuration, all configurations are transferred to the target nJAMS instance.
    The script outputs the transferred configurations.
    The script can be executed on any Linux/Unix, Windows, or Mac machine within the same network of the machine, where the source and target nJAMS Server instances are running.

    Please note:
    Passwords are transfered encrypted from source instance. That means the transferred passwords cannot be decrypted by the target instance and are therefore invalid!
    There are two options with regards to passwords:
    1. You have to reset the passwords later in the target instance
    2. Another option is to replace 'keyfile.bin' of target instance with 'keyfile.bin' from source instance. 
       'keyfile.bin' is used to encrypt/decrypt passwords and can just be copied from the source machine to the target machine. 
       The keyfile usually resides in <njams-installation-dir>/data. 
       Restart target nJAMS instance afterwards and the target instance is now able to decrypt the transferred passwords.
    Exception:
    Passwords of nJAMS user accounts are NOT transferred. 

    Characteristics:
    - transfers all or particular configurations from a source instance to a target instance
    - supports nJAMS Server instances 4.4, 5.0, and 5.1 using HTTP or TLS/HTTPS
    - script runs on Linux and macOS using PowerShell 7 or on Windows using Windows PowerShell 5 or PowerShell 7

    Preparation:
    - Source and target nJAMS instances must be up and running
    - Specified user accounts for source and target instances must be of role 'admin'. 
    - Double check if the target instance is correct and its configuration may be modified.

.PARAMETER sourceInstance
    Enter the source nJAMS instance URL, e.g. "http://source_machine:8080/njams". This parameter is mandatory.

.PARAMETER sourceUsername
    Enter username of source nJAMS instance account. Default is "admin".

.PARAMETER sourcePassword
    Enter password of source nJAMS instance account. Default is "admin".

.PARAMETER targetInstance
    Enter the target nJAMS instance URL, e.g. "http://target_machine:8080/njams". This parameter is mandatory.

.PARAMETER targetUsername
    Enter username of target nJAMS instance account. Default is "admin".

.PARAMETER targetPassword
    Enter password of target nJAMS instance account. Default is "admin".

.PARAMETER overwrite
    This option overwrites possible existing same-name configurations of DataProviders/JMS/JNDI and Users/Roles in the target instance. If 'overwrite' is not specified, the script will skip an existing configuration in the target instance with the same name. 
    The settings for 'Config', 'LDAP', 'Mail', 'Argos', and 'Indexer' are always replaced by source configuration.
    By default overwrite is off.

.PARAMETER force
    Transfers configuration without prompting for confirmation.
    By default, the script prompts for confirmation before transferring configuration. 

.PARAMETER config
    Switch to enable transfer of basic instance configuration regarding the following components: "DataProviderStatistics", "Flows", "JobController", "MainObjects", "Njams", "Notification", "Search", "Statistics", "UserManagement".
    These configurations comprise all settings provided in nJAMS UI at 'Administration > System control > System configuration'.

.PARAMETER ldap
    Switch to enable transfer of LDAP configuration.
    
.PARAMETER dataProvider
    Switch to enable transfer of Data Provider configurations including JMS and JNDI configurations. All Data Providers are stopped before in target instance.
    
.PARAMETER mail
    Switch to enable transfer of SMTP configuration.
    
.PARAMETER argos
    Switch to enable transfer of Argos configuration.
    
.PARAMETER user
    Switch to enable transfer of user accounts and roles as well as user/role assignments. Only local users and roles are transferred, synced users/roles from external system (e.g. LDAP) are not transferred.

.PARAMETER objectPrivilege
    Switch to enable transfer of domain object privileges for roles. Permissions for all domain objects will be transferred by default. Use parameters -domainObjectPath and/or -roleName in addition to limit transfer permissions only for a particular domain object path and/or for a particular role.

.PARAMETER systemPrivilege
    Switch to enable transfer of system privileges for roles. Use parameter -roleName in addition to limit transfer system privileges only for a particular role.

.PARAMETER domainObjectPath
    Specifies the domain object path, e.g. ">domain>deployment>engine>". Used in connection with parameter -objectPrivilege to limit transfer of domain object privileges only for a particular domain object path and its subordinate domain objects. 

.PARAMETER roleName
    Specifies the name of a role, e.g. "avengers". Used in connection with parameter -objectPrivileges and -systemPrivileges to limit transfer of system privileges only for a particular role.

.EXAMPLE
    ./transferInstanceConfig.ps1 -sourceInstance "http://source_machine:8080/njams" -targetInstance "http://target_machine:8080/njams"
    Transfers all configurations from source instance to target instance by using default credentials (admin/admin) for both instances.
    
.EXAMPLE
    ./transferInstanceConfig.ps1 -sourceInstance "http://source_machine:8080/njams" -sourceUsername "admin" -sourcePassword "admin" -targetInstance "http://target_machine:8080/njams" -targetUsername "admin" -targetPassword "admin"
    Transfers all configurations from source instance to target instance by using specified credentials.

.EXAMPLE
    ./transferInstanceConfig.ps1 -sourceInstance "http://source_machine:8080/njams" -targetInstance "http://target_machine:8080/njams" -dataProvider -overwrite
    Transfers configurations of Data Providers, JMS connections and JNDI connections by using default credentials. Existing configurations with the same name are replaced.

.EXAMPLE
    ./transferInstanceConfig.ps1 -sourceInstance "http://source_machine:8080/njams" -targetInstance "http://target_machine:8080/njams" -config -user
    Transfers basic instance configuration as well as user accounts and roles by using default credentials.

.EXAMPLE
    ./transferInstanceConfig.ps1 -sourceInstance "http://source_machine:8080/njams" -targetInstance "http://target_machine:8080/njams" -ldap -force
    Transfers LDAP configuration without prompting for confirmation.

.EXAMPLE
    ./transferInstanceConfig.ps1 -sourceInstance "http://source_machine:8080/njams" -targetInstance "http://target_machine:8080/njams" -objectPrivilege
    Transfers object privileges for all roles and all domain objects including all subordinate domain objects.

.EXAMPLE
    ./transferInstanceConfig.ps1 -sourceInstance "http://source_machine:8080/njams" -targetInstance "http://target_machine:8080/njams" -objectPrivilege -domainObjectPath ">domain>"
    Transfers object privileges for domain object "domain" including all subordinate domain objects.

.EXAMPLE
    ./transferInstanceConfig.ps1 -sourceInstance "http://source_machine:8080/njams" -targetInstance "http://target_machine:8080/njams" -objectPrivilege -domainObjectPath ">domain>" -roleName "avengers"
    Transfers object privileges for role "avengers" and domain object "domain" including all subordinate domain objects.

.LINK
    https://github.com/integrationmatters/njams-toolbox
    https://www.integrationmatters.com/

.NOTES
    Version:    1.0.1
    Copyright:  (c) Integration Matters
    Author:     Stephan Holters
    Date:       October 2020
#>

param (
    # Source instance:
    [Parameter(Mandatory=$true)][string]$sourceInstance = "http://os0137:8080/njams",
    [string]$sourceUsername = "admin",
    [string]$sourcePassword = "admin",
    # Target instance:
    [Parameter(Mandatory=$true)][string]$targetInstance = "http://os0102:8080/njams",
    [string]$targetUsername = "admin",
    [string]$targetPassword = "admin",
    # Options:
    # category transfer options:
    [switch]$config,
    [switch]$ldap,
    [switch]$dataProvider,
    [switch]$mail,
    [switch]$argos,
    [switch]$user,
    [switch]$objectPrivilege,
    [Alias("path")][string]$domainObjectPath = ">",
    [Alias("role")][string]$roleName,
    [switch]$systemPrivilege,
    # general transfer options:
    [switch]$overwrite,
    [switch]$force
    )

# Check for configurations to transfer:
$transferAll = $false
if ($PSBoundParameters.ContainsKey('config') -eq $false -and
    $PSBoundParameters.ContainsKey('ldap') -eq $false -and
    $PSBoundParameters.ContainsKey('dataProvider') -eq $false -and
    $PSBoundParameters.ContainsKey('mail') -eq $false -and
    $PSBoundParameters.ContainsKey('argos') -eq $false -and
    $PSBoundParameters.ContainsKey('indexer') -eq $false -and
    $PSBoundParameters.ContainsKey('user') -eq $false -and
    $PSBoundParameters.ContainsKey('objectPrivilege') -eq $false -and
    $PSBoundParameters.ContainsKey('systemPrivilege') -eq $false) {

    $transferAll = $True
}

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

# General header for request:
$reqHeader = @{"Authorization" = "Basic"+[System.Convert]::ToBase64String([System.Text.Encoding]::UTF8.GetBytes('"$username:$password"'))}

# This function calls nJAMS Rest/API and returns result:
function fnCallRestApi ($method, $requestHeader, $contentType, $requestBody, $uri, $session) {
    # Calls nJAMS Rest/API depending on psversion and request body:
    if ($requestBody) {
        if ($PSVersionTable.PSEdition -eq "Core") {
            $responseObject = Invoke-RestMethod -Method $method -Header $requestHeader -ContentType $contentType -SkipCertificateCheck -Body $requestBody -uri $uri -WebSession $session
        }
        else {
            $responseObject = Invoke-RestMethod -Method $method -Header $requestHeader -ContentType $contentType -Body $requestBody -uri $uri -WebSession $session
        }
    }
    else {
        if ($PSVersionTable.PSEdition -eq "Core") {
            $responseObject = Invoke-RestMethod -Method $method -Header $requestHeader -ContentType $contentType -SkipCertificateCheck -uri $uri -WebSession $session
        }
        else {
            $responseObject = Invoke-RestMethod -Method $method -Header $requestHeader -ContentType $contentType -uri $uri -WebSession $session
        }
    }
    
    return $responseObject
}

function fnStopDataProviders ($tgtInstance, $tgtWebSession) {

    # Get list of running Data Providers:
    $targetRequestBody = '{ "start": "false" }'
        
    if ($PSVersionTable.PSEdition -eq "Core") {
        $targetDataProviderObject = Invoke-RestMethod -Method GET -Header $reqHeader -SkipCertificateCheck -uri "$tgtInstance/api/dataprovider" -WebSession $tgtWebSession
    }
    else {
        $targetDataProviderObject = Invoke-RestMethod -Method GET -Header $reqHeader -uri "$tgtInstance/api/dataprovider" -WebSession $tgtWebSession
    }

    # Loop through list of Data Providers:
    Foreach ($dataProvider in $targetDataProviderObject | where-object { $_.state -eq "RUNNING" })
    {
        # Define target request body:
        $targetRequestBody = '{ "start": "false" }'
        
        $targetResult = $null
        $targetResult = fnCallRestApi "PUT" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/dataprovider/$($dataProvider.id)" $tgtWebSession

        if ($targetResult) {
            write-host "Data provider '$($dataProvider.name)' stopped."
        }
    }

    return $true
}

function fnStopIndexer ($tgtInstance, $tgtWebSession) {

    # Define target request body:
    $targetRequestBody = '{ "start": "false" }'
    
    $targetResult = $null
    $targetResult = fnCallRestApi "PUT" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/indexer/component" $tgtWebSession

    if ($targetResult) {
        write-host "Indexer stopped."
    }
}

function fnTransferJNDIConfig ($srcInstance, $srcWebSession, $tgtInstance, $tgtWebSession, $optOverwrite) {
    # Get configurations from source instance:
    $sourceJNDIConfigObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$srcInstance/api/jndiconnection" $srcWebSession

    # Get possible existing configurations from target instance:
    $targetJNDIConfigObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$tgtInstance/api/jndiconnection" $tgtWebSession

    # Loop through source configurations:
    Foreach ($sourceConfig in $sourceJNDIConfigObject)
    {
        # Define target request body:
        $targetRequestObject = [PSCustomObject]@{
            "name" = $($sourceConfig.name)
            "properties" = $($sourceConfig.properties)
        }

        # Convert custom object to JSON:
        $targetRequestBody = $targetRequestObject | ConvertTo-Json

        # Check for existing configuration in target instance:
        $targetConfig = $targetJNDIConfigObject | where-object { $_.name -eq $($sourceConfig.name) }

        if (!$targetConfig) {

            # Add new configuration to target instance
            $targetResult = $null
            $targetResult = fnCallRestApi "POST" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/jndiconnection" $tgtWebSession

            if ($targetResult) {
                write-host "JNDI config '$($sourceConfig.name)' transfered."
            }
        }
        else {
            # If overwrite option is true, update existing configuration:
            if ($optOverwrite) {
                # Use current id and modcount of target config:
                $targetRequestObject | Add-Member -MemberType NoteProperty -Name "id" -Value $($targetConfig.id)
                $targetRequestObject | Add-Member -MemberType NoteProperty -Name "modcount" -Value $($targetConfig.modcount)

                # Convert custom object to JSON:
                $targetRequestBody = $targetRequestObject | ConvertTo-Json

                # Overwrite existing target configuration with source configuration:
                $targetResult = $null
                $targetResult = fnCallRestApi "PUT" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/jndiconnection" $tgtWebSession

                if ($targetResult) {
                    write-host "Existing JNDI config in target instance updated: '$($targetConfig.name)'"
                }
            }
            else {
                write-host "Existing JNDI config '$($targetConfig.name)' found in target instance. Transfer skipped."
            }
        }
    } 

    return $sourceJNDIConfigObject
}

function fnTransferJMSConfig ($srcInstance, $srcWebSession, $tgtInstance, $tgtWebSession, $optOverwrite, $srcJNDIConfigObject) {
    # Get configurations from source instance:
    $sourceJMSConfigObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$srcInstance/api/jmsconnection" $srcWebSession

    # Get possible existing configurations from target instance:
    $targetJMSConfigObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$tgtInstance/api/jmsconnection" $tgtWebSession
    
    # Get existing JNDI configurations from target instance to be able to reference JMS connection to the corresponding JNDI connection:
    $targetJNDIConfigObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$tgtInstance/api/jndiconnection" $tgtWebSession

    # Loop through source configurations:
    Foreach ($sourceConfig in $sourceJMSConfigObject)
    {
        # Define target request body:
        $targetRequestObject = [PSCustomObject]@{
            "name" = $($sourceConfig.name)
            "provider" = $($sourceConfig.provider)
            "username" = $($sourceConfig.username)
            "password" = $($sourceConfig.password)
            "destination" = $($sourceConfig.destination)
            "responseQueue" = $($sourceConfig.responseQueue)
            "monitoring" = $($sourceConfig.monitoring)
            "useSsl" =  $($sourceConfig.useSsl)
        }

        # If there is a reference to JNDI connection:
        if ($($sourceConfig.jndiConnection) -gt "0") {
            # Take source JNDI config id and get JNDI config name. Take this name to request JNDI config id from target:
            $jndiSourceConfig = $srcJNDIConfigObject | where-object { $_.id -eq $($sourceConfig.jndiConnection) }
            $jndiSourceName = $($jndiSourceConfig.name)
            $jndiTargetConfig = $targetJNDIConfigObject | where-object { $_.name -eq $($jndiSourceName) }
            $jndiTargetId = $($jndiTargetConfig.id)

            # Add members for JNDI reference:
            $targetRequestObject | Add-Member -MemberType NoteProperty -Name "jndiConnection" -Value $($jndiTargetId)
            $targetRequestObject | Add-Member -MemberType NoteProperty -Name "connectionFactory" -Value $($sourceConfig.connectionFactory)
        }
        else {
            # In case there is no JNDI reference, add 'providerUrl':
            $targetRequestObject | Add-Member -MemberType NoteProperty -Name "providerUrl" -Value $($sourceConfig.providerUrl)
        }

        if ($($sourceConfig.useSsl) -eq "true") {
            $targetRequestObject | Add-Member -MemberType NoteProperty -Name "emsSslConnectionConfig" -Value @{
                "sslTrace" = $($sourceConfig.emsSslConnectionConfig.sslTrace)
                "sslDebugTrace" = $($sourceConfig.emsSslConnectionConfig.sslDebugTrace)
                "trustedCertificates" = $($sourceConfig.emsSslConnectionConfig.trustedCertificates)
                "expectedHostname" = $($sourceConfig.emsSslConnectionConfig.expectedHostname)
                "publicKey" = $($sourceConfig.emsSslConnectionConfig.publicKey)
                "privateKey" = $($sourceConfig.emsSslConnectionConfig.privateKey)
                "privateKeyPassword" = $($sourceConfig.emsSslConnectionConfig.privateKeyPassword)
                "sslVendor" = $($sourceConfig.emsSslConnectionConfig.sslVendor)
                "sslCiphers" = $($sourceConfig.emsSslConnectionConfig.sslCiphers)
            }
        }

        # Convert custom object to JSON:
        $targetRequestBody = $targetRequestObject | ConvertTo-Json

        # Check for existing configuration in target instance:
        $targetConfig = $targetJMSConfigObject | where-object { $_.name -eq $($sourceConfig.name) }

        if (!$targetConfig) {

            # Add new configuration to target instance
            $targetResult = $null
            $targetResult = fnCallRestApi "POST" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/jmsconnection" $tgtWebSession

            if ($targetResult) {
                write-host "JMS config '$($sourceConfig.name)' transfered."
            }
        }
        else {
            # If overwrite option is true, update existing target configuration:
            if ($optOverwrite) {

                # Use current id and modcount of target config:
                $targetRequestObject | Add-Member -MemberType NoteProperty -Name "id" -Value $($targetConfig.id)
                $targetRequestObject | Add-Member -MemberType NoteProperty -Name "modcount" -Value $($targetConfig.modcount)

                # Convert custom object to JSON:
                $targetRequestBody = $targetRequestObject | ConvertTo-Json

                # Overwrite existing target configuration with source configuration:
                $targetResult = $null
                $targetResult = fnCallRestApi "PUT" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/jmsconnection" $tgtWebSession

                if ($targetResult) {
                    write-host "Existing JMS config in target instance updated: '$($targetConfig.name)'"
                }
            }
            else {
                write-host "Existing JMS config '$($targetConfig.name)' found in target instance. Transfer skipped."
            }
        }
    } 
    return $sourceJMSConfigObject
}

function fnTransferDPConfig ($srcInstance, $srcWebSession, $tgtInstance, $tgtWebSession, $optOverwrite, $srcJMSConfigObject) {
    # Get configurations from source instance:
    $sourceDPConfigObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$srcInstance/api/jmsdataproviderconfig" $srcWebSession

    # Get possible existing configurations from target instance:
    $targetDPConfigObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$tgtInstance/api/jmsdataproviderconfig" $tgtWebSession
    
    # Get existing JMS configurations from target instance to be able to reference DP config to the corresponding JMS connection:
    $targetJMSConfigObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$tgtInstance/api/jmsconnection" $tgtWebSession

    # Loop through source configurations:
    Foreach ($sourceConfig in $sourceDPConfigObject)
    {
        # Take source JMS config id and get JMS config name. Take this name to request JMS config id from target:
        $jmsSourceConfig = $srcJMSConfigObject | where-object { $_.id -eq $($sourceConfig.jmsConnectionConfig.id) }
        $jmsSourceName = $($jmsSourceConfig.name)
        $jmsTargetConfig = $targetJMSConfigObject | where-object { $_.name -eq $($jmsSourceName) }
        $jmsTargetId = $($jmsTargetConfig.id)

        # Define target request body:
        $targetRequestObject = [PSCustomObject]@{
            "name" = $($sourceConfig.name)
            "threadCount" = $($sourceConfig.threadCount)
            "startup" = $($sourceConfig.startup)
            "dataProviderType" = $($sourceConfig.dataProviderType)
            "jmsConnection" = $jmsTargetId
        }

        # Convert custom object to JSON:
        $targetRequestBody = $targetRequestObject | ConvertTo-Json

        # Check for existing configuration in target instance:
        $targetConfig = $targetDPConfigObject | where-object { $_.name -eq $($sourceConfig.name) }

        if (!$targetConfig) {

            # Add new configuration to target instance
            $targetResult = $null
            $targetResult = fnCallRestApi "POST" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/jmsdataproviderconfig" $tgtWebSession

            # Link Data Provider with JMS connection:
            $targetResult = fnCallRestApi "PUT" $reqHeader "application/json" $null "$tgtInstance/api/jmsdataproviderconfig/name/$($targetRequestObject.name)/jmsconnection/name/$($jmsTargetConfig.name)" $tgtWebSession

            if ($targetResult) {
                write-host "DP config '$($sourceConfig.name)' transfered."
            }
        }
        else {
            # If overwrite option is true, update existing target configuration:
            if ($optOverwrite) {

                # Use current id and modcount of target config:
                $targetRequestObject | Add-Member -MemberType NoteProperty -Name "id" -Value $($targetConfig.id)
                $targetRequestObject | Add-Member -MemberType NoteProperty -Name "modcount" -Value $($targetConfig.modcount)
                $targetRequestObject | Add-Member -MemberType NoteProperty -Name "state" -Value $($targetConfig.state)

                # Convert custom object to JSON:
                $targetRequestBody = $targetRequestObject | ConvertTo-Json

                # Overwrite existing target configuration with source configuration:
                $targetResult = $null
                $targetResult = fnCallRestApi "PUT" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/jmsdataproviderconfig" $tgtWebSession

                # Overwrite link to JMS connection:
                $targetResult = fnCallRestApi "PUT" $reqHeader "application/json" $null "$tgtInstance/api/jmsdataproviderconfig/name/$($targetRequestObject.name)/jmsconnection/name/$($jmsTargetConfig.name)" $tgtWebSession

                if ($targetResult) {
                    write-host "Existing DP config in target instance updated: '$($targetConfig.name)'"
                }
            }
            else {
                write-host "Existing DP config '$($targetConfig.name)' found in target instance. Transfer skipped."
            }
        }
    }
    return $sourceDPConfigObject
}

function fnTransferSimpleConfig ($srcInstance, $srcWebSession, $tgtInstance, $tgtWebSession, $optOverwrite, $configName, $method, $apiCall) {
    # Get configurations from source instance:
    $sourceSimpleConfigObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$srcInstance/$apiCall" $srcWebSession

    # Convert custom object to JSON:
    $targetRequestBody = $sourceSimpleConfigObject | ConvertTo-Json

    # Update configuration in target instance
    $targetResult = $null
    $targetResult = fnCallRestApi $method $reqHeader "application/json" $targetRequestBody "$tgtInstance/$apiCall" $tgtWebSession

    if ($targetResult) {
        write-host "$configName config transfered."
    }

    return $sourceSimpleConfigObject
}

function fnTransferRoles ($srcInstance, $srcWebSession, $tgtInstance, $tgtWebSession, $optOverwrite) {
    # Get configurations from source instance:
    $sourceRolesObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$srcInstance/api/usermanagement/roles" $srcWebSession

    # Get possible existing configurations from target instance:
    $targetRolesObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$tgtInstance/api/usermanagement/roles" $tgtWebSession

    # Loop through source configurations:
    Foreach ($sourceConfig in $sourceRolesObject | where-object { [string]::IsNullOrEmpty($_.externalSystem) })
    {
        # Define target request body:
        $targetRequestObject = [PSCustomObject]@{
            "rolename" = $($sourceConfig.rolename)
            "comment" = $($sourceConfig.comment)
            "userRole" = $($sourceConfig.userRole)
            "externalSystem" = $($sourceConfig.externalSystem)
            "externalId" = $($sourceConfig.externalId)
            "hasSystemPrivileges" = $($sourceConfig.hasSystemPrivileges)
            "propertyMap" = $($sourceConfig.propertyMap)
        }

        # Convert custom object to JSON:
        $targetRequestBody = $targetRequestObject | ConvertTo-Json

        # Check for existing configuration in target instance:
        $targetConfig = $targetRolesObject | where-object { $_.rolename -eq $($sourceConfig.rolename) }

        if (!$targetConfig) {

            # Add new configuration to target instance
            $targetResult = $null
            $targetResult = fnCallRestApi "POST" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/usermanagement/roles" $tgtWebSession

            if ($targetResult) {
                write-host "Role '$($sourceConfig.rolename)' transfered."
            }
        }
        else {
            # If overwrite option is true, update existing configuration:
            if ($optOverwrite) {
                # Use current id and modcount of target config:
                $targetRequestObject | Add-Member -MemberType NoteProperty -Name "id" -Value $($targetConfig.id)
                $targetRequestObject | Add-Member -MemberType NoteProperty -Name "modcount" -Value $($targetConfig.modcount)

                # Convert custom object to JSON:
                $targetRequestBody = $targetRequestObject | ConvertTo-Json

                # Overwrite existing target configuration with source configuration:
                $targetResult = $null
                $targetResult = fnCallRestApi "PUT" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/usermanagement/roles" $tgtWebSession
                
                if ($targetResult) {
                    write-host "Existing role in target instance updated: '$($targetConfig.rolename)'"
                }
            }
            else {
                write-host "Existing role '$($targetConfig.rolename)' found in target instance. Transfer skipped."
            }
        }
    } 

    return $sourceRolesObject
}

function fnTransferUsers ($srcInstance, $srcWebSession, $tgtInstance, $tgtWebSession, $optOverwrite) {
    # Get configurations from source instance:
    $sourceUsersObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$srcInstance/api/usermanagement/users" $srcWebSession

    # Get possible existing configurations from target instance:
    $targetUsersObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$tgtInstance/api/usermanagement/users" $tgtWebSession

    # Loop through source configurations:
    Foreach ($sourceConfig in $sourceUsersObject | where-object { [string]::IsNullOrEmpty($_.externalSystem) })
    {
        # Define target request body:
        $targetRequestObject = [PSCustomObject]@{
            "username" = $($sourceConfig.username)
            "firstname" = $($sourceConfig.firstname)
            "lastname" = $($sourceConfig.lastname)
            "email" = $($sourceConfig.email)
            "comment" = $($sourceConfig.comment)
            "validFrom" = $($sourceConfig.validFrom)
            "validTo" = $($sourceConfig.validTo)
            "externalSystem" = $($sourceConfig.externalSystem)
            "externalId" = $($sourceConfig.externalId)
            #"propertyMap" = $($sourceConfig.propertyMap)
            }

        # Convert custom object to JSON:
        $targetRequestBody = $targetRequestObject | ConvertTo-Json

        # Check for existing configuration in target instance:
        $targetConfig = $targetUsersObject | where-object { $_.username -eq $($sourceConfig.username) }

        if (!$targetConfig) {

            # Add new configuration to target instance
            $targetResult = $null
            $targetResult = fnCallRestApi "POST" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/usermanagement/users" $tgtWebSession

            if ($targetResult) {
                write-host "User '$($sourceConfig.username)' transfered."
            }
        }
        else {
            # If overwrite option is true, update existing configuration:
            if ($optOverwrite) {
                # Use current id and modcount of target config:
                $targetRequestObject | Add-Member -MemberType NoteProperty -Name "id" -Value $($targetConfig.id)
                $targetRequestObject | Add-Member -MemberType NoteProperty -Name "modcount" -Value $($targetConfig.modcount)

                # Convert custom object to JSON:
                $targetRequestBody = $targetRequestObject | ConvertTo-Json

                # Overwrite existing target configuration with source configuration:
                $targetResult = $null
                $targetResult = fnCallRestApi "PUT" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/usermanagement/users" $tgtWebSession

                if ($targetResult) {
                    write-host "Existing user in target instance updated: '$($targetConfig.username)'"
                }
            }
            else {
                write-host "Existing user '$($targetConfig.username)' found in target instance. Transfer skipped."
            }
        }
    } 

    return $sourceUsersObject
}

function fnTransferUsersRoles ($srcInstance, $srcWebSession, $tgtInstance, $tgtWebSession, $optOverwrite, $srcRolesObject) {

    # Get roles from target instance:
    $targetRolesObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$tgtInstance/api/usermanagement/roles" $tgtWebSession

    # Get users from target instance:
    $targetUsersObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$tgtInstance/api/usermanagement/users" $tgtWebSession

    # Loop through roles of source instance that do not come from external system:
    Foreach ($srcRole in $srcRolesObject | where-object { [string]::IsNullOrEmpty($_.externalSystem) })
    {
        # Get matching role from target instance:
        $tgtRole = $targetRolesObject | where-object { $_.rolename -eq $($srcRole.rolename) }

        # Get users of this role from source instance:
        $sourceUsersObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$srcInstance/api/usermanagement/roles/$($srcRole.id)/users" $srcWebSession

        if ($sourceUsersObject) {
            # Loop through users of this role in source instance:
            Foreach ($srcUser in $sourceUsersObject)
            {
                # Get matching user from target instance:
                $tgtUser = $targetUsersObject | where-object { $_.username -eq $($srcUser.username) }

                # Add user to role in target instance:
                try {
                    $targetResult = $null
                    # If there is a matching user in target instance, add user to role in target instance:
                    if ($tgtUser) {
                        $targetResult = fnCallRestApi "PUT" $reqHeader "text/plain" $($tgtUser.id) "$tgtInstance/api/usermanagement/roles/$($tgtRole.id)/user" $tgtWebSession

                        write-host "User $($tgtUser.username) ($($tgtUser.id)) added to role $($tgtRole.rolename) ($($tgtRole.id))"
                    }
                }
                catch {
                    if ($PSVersionTable.PSEdition -eq "Core") {
                        $parsedError = $_.ErrorDetails.Message | ConvertFrom-Json
                    }
                    else {
                        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                        $reader.BaseStream.Position = 0
                        $reader.DiscardBufferedData()
                        $parsedError = $reader.ReadToEnd() | ConvertFrom-Json
                    }

                    # If user/role assignment already exist, continue silently:
                    if ($($parsedError.errorCode) -eq "00005") {

                        write-host $($parsedError.message)
                        Continue
                    }
                    # Else print error and exit script.
                    else {
                        write-host "Error calling nJAMS Rest/API due to:" -ForegroundColor Red
                        write-host "$_.Exception.Message"

                        Exit
                    }
                }
            }
        }
    }
    return $true
}

function fnTransferConfig ($srcInstance, $srcWebSession, $tgtInstance, $tgtWebSession, $optOverwrite) {

    # Array of components to transfer:
    $componentList = @("DataProviderStatistics", "Flows", "JobController", "MainObjects", "Njams", "Notification", "Search", "Statistics", "UserManagement")

    Foreach ($component in $componentList) 
    {
        # Get configuration of component Njams from source instance:
        $sourceConfigObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$srcInstance/api/configuration/$component/*" $srcWebSession

        # Loop through source configurations:
        Foreach ($sourceConfig in $sourceConfigObject)
        {
            # Define target request body:
            $targetRequestObject = [PSCustomObject]@{
                "component" = $($sourceConfig.component)
                "name" = $($sourceConfig.name)
                "valueType" = $($sourceConfig.valueType)
                "publicAccessible" = $($sourceConfig.publicAccessible)
                "value" = $($sourceConfig.value)
            }

            # Convert custom object to JSON:
            $targetRequestBody = $targetRequestObject | ConvertTo-Json

            # Add new configuration to target instance
            $targetResult = fnCallRestApi "POST" $reqHeader "application/json" $targetRequestBody "$tgtInstance/api/configuration" $tgtWebSession

            if ($targetResult) {
                write-host "Config '$($sourceConfig.name)' of component '$($sourceConfig.component)' transfered."
            }
        }
    }
    return $true
}

function fnGetDomainObjectListByPath ($instance, $webSession, $objectPath) {
    # Get list of sub domain objects by path from given instance:

    try {
        # Encode objectPath:
        $encodedObjectPath = [System.Web.HttpUtility]::UrlEncode($objectPath)

        # Get list of domain objects:
        $domainObjectList = fnCallRestApi "GET" $reqHeader "application/json" $null "$instance/api/domainobject/path/$encodedObjectPath" $webSession
    }
    catch {
        if ($PSVersionTable.PSEdition -eq "Core") {
            $parsedError = $_.ErrorDetails.Message | ConvertFrom-Json
        }
        else {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $parsedError = $reader.ReadToEnd() | ConvertFrom-Json
        }

        # If domain object is not found in instance:
        if ($($parsedError.errorCode) -eq "00076") {

            $domainObjectList = $null
        }
        # Else exit script:
        else {
            write-host "Error calling nJAMS Rest/API due to:" -ForegroundColor Red
            write-host "$_.Exception.Message"

            Exit
        }
    }

    return $domainObjectList
}
function fnGetDomainObjectByPath ($instance, $webSession, $objectPath) {
    # Get domain object by path from given instance:
    try {
        # Define target request body:
        $targetRequestObject = [PSCustomObject]@{
            "objectType" = "DO"
            "objectPath" = $objectPath
        }

        # Convert custom object to JSON:
        $requestBody = $targetRequestObject | ConvertTo-Json

        # Get id of domain object of target instance:
        $domainObject = fnCallRestApi "POST" $reqHeader "application/json" $requestBody "$instance/api/mainobject" $webSession

    }
    catch {
        if ($PSVersionTable.PSEdition -eq "Core") {
            $parsedError = $_.ErrorDetails.Message | ConvertFrom-Json
        }
        else {
            $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
            $reader.BaseStream.Position = 0
            $reader.DiscardBufferedData()
            $parsedError = $reader.ReadToEnd() | ConvertFrom-Json
        }

        # If domain object is not found in instance:
        if ($($parsedError.errorCode) -eq "00076") {

            $domainObject = $null
        }
        # Else exit script:
        else {
            write-host "Error calling nJAMS Rest/API due to:" -ForegroundColor Red
            write-host "$_.Exception.Message"

            Exit
        }
    }

    return $domainObject
}

function fnTransferDomainObjectPrivs ($srcInstance, $srcWebSession, $tgtInstance, $tgtWebSession, $objectPath, $optOverwrite) {
    # Transfer privileges of a given domain object from source instance to target insance.

    $examineNextLevel = $false

    # Get domain object by given path of source instance:
    $sourceDomainObjects = fnGetDomainObjectByPath $srcInstance $srcWebSession $objectPath

    if ($sourceDomainObjects) {
        Foreach ($sourceDO in $sourceDomainObjects) 
        {
            # Get corresponding domain object from target instance:
            $targetDomainObject = fnGetDomainObjectByPath $tgtInstance $tgtWebSession $objectPath

            if ($targetDomainObject) {

                # Set privileges for role on domain object in target instance:
                $examineNextLevel = fnSetDomainObjectPrivs $srcInstance $srcWebSession $tgtInstance $tgtWebSession $($sourceDO.id) $($targetDomainObject.id)

                # In case we encounter privilege UNDETERMINED, the domain object level below has to be examined too:
                if ($examineNextLevel -eq $true) {
                    # Get sub elements of object path in source instance:
                    $sourceDomainObjectList = fnGetDomainObjectListByPath $srcInstance $srcWebSession $objectPath

                    # Loop through list of domain objects and transfer privileges:
                    Foreach ($sourceDomainObject in $sourceDomainObjectList) 
                    {
                        fnTransferDomainObjectPrivs $srcInstance $srcWebSession $tgtInstance $tgtWebSession $($sourceDomainObject.objectPath) $overwrite
                    }
                }
            }
        }
    }

    return $true
}


function fnSetDomainObjectPrivs ($srcInstance, $srcWebSession, $tgtInstance, $tgtWebSession, $srcDomainObjectId, $tgtDomainObjectId) {
    # 1. Walk through domain object tree of source instance and get object privileges for all roles of each domain object 
    # 2. Find equivalent domain object in target instance 
    # 3. Find equivalent role in target instance
    # 4. Set object privilege for target role of target domain object

    # Get object privileges from domain object of source instance:
    $sourceDOPrivilegeObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$srcInstance/api/usermanagement/objects/all/DO/$srcDomainObjectId" $srcWebSession

    # If applicable, filter domain privilege object of source instance by specified role:
    if ($roleName) {
        $sourceDOPrivilegeObject = $sourceDOPrivilegeObject | where-object { $_.rolename -match $roleName }
    }

    # Initialize required examination of next level of domain object below:
    $examineNextLevel = $false

    # Loop through permissions granted to roles for domain object of source instance:
    Foreach ($sourceDOPriv in $sourceDOPrivilegeObject) 
    {
        # Find equivalent role in target instance:
        $targetRole = $targetRolesBasicObject | where-object { $_.rolename -eq $($sourceDOPriv.rolename) }

        # Continue, if role in target instance has not Admin system privilege:
        if (!$($targetRole.admin)) {

            # Continue looping, if role exists in target instance:
            if ($targetRole) {
                # Loop through categories of privileges in source instance:
                Foreach ($sourceDOPrivCategory in $sourceDOPriv.categories) 
                {
                    # Loop through category names:
                    foreach ($sourceCategoryName in $sourceDOPrivCategory.psobject.properties.name) 
                    {
                        # Loop through privileges:
                        Foreach ($sourcePriv in $sourceDOPrivCategory.$($sourceCategoryName)) 
                        {
                            # Loop through privilege names:
                            foreach ($privName in $sourcePriv.psobject.properties.name) 
                            {
                                # write-host $sourcePriv.$($privName)
                                # Grant permission on domain object for role in target instance:
                                try {
                                    if ($sourcePriv.$($privName) -eq "GRANTED") {
                                        
                                        fnCallRestApi "PUT" $reqHeader "application/json" $null "$tgtInstance/api/usermanagement/objects/$($targetRole.id)/DO/$tgtDomainObjectId/$sourceCategoryName/$privName" $tgtWebSession

                                        write-host "Granted privilege '$privName' on role '$($targetRole.roleName)' for '$($sourceDOPriv.path)'."
                                    }

                                    # Revoke permission on domain object for role in target instance:
                                    if ($sourcePriv.$($privName) -eq "NOT_GRANTED") {
                                        
                                        fnCallRestApi "DELETE" $reqHeader "application/json" $null "$tgtInstance/api/usermanagement/objects/$($targetRole.id)/DO/$tgtDomainObjectId/$sourceCategoryName/$privName" $tgtWebSession

                                        write-host "Revoked privilege '$privName' on role '$($targetRole.roleName)' for '$($sourceDOPriv.path)'."
                                    }
                                }
                                catch {
                                    if ($PSVersionTable.PSEdition -eq "Core") {
                                        $parsedError = $_.ErrorDetails.Message | ConvertFrom-Json
                                    }
                                    else {
                                        $reader = New-Object System.IO.StreamReader($_.Exception.Response.GetResponseStream())
                                        $reader.BaseStream.Position = 0
                                        $reader.DiscardBufferedData()
                                        $parsedError = $reader.ReadToEnd() | ConvertFrom-Json
                                    }
                
                                    # If role is admin, continue silently:
                                    if ($($parsedError.errorCode) -eq "00152") {
                
                                        write-host $($parsedError.message)
                                        Continue
                                    }
                                    # Else print error and exit script.
                                    else {
                                        write-host "Error calling nJAMS Rest/API due to:" -ForegroundColor Red
                                        write-host "Granting privilege '$privName' on role '$($targetRole.roleName)' for '$($sourceDOPriv.path)' failed." -ForegroundColor Red
                                        write-host "$_.Exception.Message"
                
                                        Exit
                                    }
                                }
                
                                # If privilege is UNDETERMINED, the next level below this domain object has to be examined for transferring permissions:
                                if ($sourcePriv.$($privName) -eq "UNDETERMINED") {
                                    $examineNextLevel = $true
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    return $examineNextLevel
}

function fnTransferSystemPrivs ($srcInstance, $srcWebSession, $tgtInstance, $tgtWebSession) {
# This ifunction transfers all system privileges of roles in source instance to roles in target instance.
# 1. Get all roles of source instance
# 2. Get all roles of target instance
# 3. Get all available system privileges of source instance
# 4. Get all available system privileges of target instance
# 5. Loop through roles of source instance, determine sysprivs of each role, and apply sysprivs to role in target instance

    # 1. Get all roles of source instance:
    $sourceRolesObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$srcInstance/api/usermanagement/roles/basic" $srcWebSession
    if (!$sourceRolesObject) {
        return $false
    }

    # If applicable, filter roles object of source instance by specified role:
    if ($roleName) {
        $sourceRolesObject = $sourceRolesObject | where-object { $_.rolename -eq $roleName }
    }

    # 2. Get all roles of target instance:
    $targetRolesObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$tgtInstance/api/usermanagement/roles" $tgtWebSession
    if (!$targetRolesObject) {
        return $false
    }

    # If applicable, filter roles object of target instance by specified role:
    if ($roleName) {
        $targetRolesObject = $targetRolesObject | where-object { $_.rolename -eq $roleName }
    }

    # 3. Get all available system privileges of source instance:
    $sourceSystemPrivilegesObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$srcInstance/api/usermanagement/privileges" $srcWebSession
    if (!$sourceSystemPrivilegesObject) {
        return $false
    }

    # 4. Get all available system privileges of target instance:
    $targetSystemPrivilegesObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$tgtInstance/api/usermanagement/privileges" $tgtWebSession
    if (!$targetSystemPrivilegesObject) {
        return $false
    }

    # 5. Loop through roles of source instance, determine sysprivs of each role, and apply sysprivs to role in target instance:
    Foreach ($sourceRole in $sourceRolesObject | where-object { [string]::IsNullOrEmpty($_.hasSystemPrivileges) })
    {
        # Get list of sysprivs of role in source instance:
        $sourceRoleSystemPrivilegeObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$srcInstance/api/usermanagement/roles/$($sourceRole.id)/privileges" $srcWebSession

        if ($sourceRoleSystemPrivilegeObject) {
            # Loop through system privileges of role in source instance:
            Foreach ($sourceRoleSystemPrivilege in $sourceRoleSystemPrivilegeObject) 
            {
                # Get corresponding role in target instance:
                $targetRole = $targetRolesObject | where-object { $_.rolename -eq $($sourceRole.rolename)}

                if ($targetRole) {
                    # Get corresponding syspriv id in target instance:
                    $targetSyspriv = $targetSystemPrivilegesObject | where-object { $_.privilegeRightName -eq $($sourceRoleSystemPrivilege.privilegeRightName)}

                    if ($targetSyspriv) {
                        # Geant system privilege to role in target instance:
                        # curl -X PUT --header 'Content-Type: text/plain' --header 'Accept: text/plain' -d '115' 'http://10.189.0.137:8080/njams/api/usermanagement/roles/5276/privilege'

                        write-host "Grant system privilege '$($targetSyspriv.privilegeRightName)' for role '$($targetRole.rolename)' in target instance"
                        fnCallRestApi "PUT" $reqHeader "text/plain" $($targetSyspriv.id) "$tgtInstance/api/usermanagement/roles/$($targetRole.id)/privilege" $tgtWebSession
                    }
                }
            }
        }
    }

    return $true
}

# (1) Login:
# (1.a) Login into source instance:
$sourceRequestBody = '{ "username": "' + $sourceUsername + '" , ' + '"password": "' + $sourcePassword + '" }'
$sourceSession = $null #empty variable session
try {
    $sourceUserId = $null
    if ($PSVersionTable.PSEdition -eq "Core") {
        $sourceUserId = Invoke-RestMethod -Method POST -Header $reqHeader -ContentType "application/json" -SkipCertificateCheck -Body $sourceRequestBody -uri "$sourceInstance/api/usermanagement/authentication" -SessionVariable sourceSession
    }
    else {
        $sourceUserId = Invoke-RestMethod -Method POST -Header $reqHeader -ContentType "application/json" -Body $sourceRequestBody -uri "$sourceInstance/api/usermanagement/authentication" -SessionVariable sourceSession
    }
} 
catch {
    write-host "Unable to login into source nJAMS instance due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"
    
    Exit
}

# (1.b) Login into target instance:
$targetRequestBody = '{ "username": "' + $targetUsername + '" , ' + '"password": "' + $targetPassword + '" }'
$targetSession = $null #empty variable session
try {
    $targetUserId = $null
    if ($PSVersionTable.PSEdition -eq "Core") {
        $targetUserId = Invoke-RestMethod -Method POST -Header $reqHeader -ContentType "application/json" -SkipCertificateCheck -Body $targetRequestBody -uri "$targetInstance/api/usermanagement/authentication" -SessionVariable targetSession
    }
    else {
        $targetUserId = Invoke-RestMethod -Method POST -Header $reqHeader -ContentType "application/json" -Body $targetRequestBody -uri "$targetInstance/api/usermanagement/authentication" -SessionVariable targetSession
    }
} 
catch {
    write-host "Unable to login into target nJAMS instance due to:" -ForegroundColor Red
    write-host "$_.Exception.Message"

    Exit
}

# (2) Transfer specified configurations:
if ($sourceUserId -and $targetUserId) {

    # Confirm transfer to target instance:
    if (!$force) {
        write-host "Logged in successfully into source and target instances."
        write-host "You are going to transfer configuration from source nJAMS instance '$sourceInstance' to target '$targetInstance'. Configuration of target instance will be changed. " -ForegroundColor Yellow

        $userInput = read-host "Do you want to continue? [Y] Yes  [N] No"

        if ($userInput.ToLower() -ne "y" -and $userInput.ToLower() -ne "yes") {
            write-host "Ok, transfer is not executed. Target instance remains unchanged."
        
            Exit
        }
    }

    # Transfer Data Provider(s) including JMS and JNDI connection(s):
    try {
        if ($dataProvider -or $transferAll) {
            
            # Stop existing Data Providers in target instance:
            $result = $null
            $result = fnStopDataProviders $targetInstance $targetSession

            if ($result) {
                # Transfer configs of JNDI connections:
                $objectJNDIConfig = fnTransferJNDIConfig $sourceInstance $sourceSession $targetInstance $targetSession $overwrite

                # Transfer configs of JMS connections:
                $objectJMSConfig = fnTransferJMSConfig $sourceInstance $sourceSession $targetInstance $targetSession $overwrite $objectJNDIConfig

                # Transfer configs of Data Providers:
                $objectDPConfig = fnTransferDPConfig $sourceInstance $sourceSession $targetInstance $targetSession $overwrite $objectJMSConfig

                if ($objectDPConfig) {
                    write-host "Transferring Data Provider(s) finished."
                }
            }
        }
    }
    catch {
        write-host "Unable to transfer Data Provider configurations due to:" -ForegroundColor Red
        write-host "$_.Exception.Message"
    
        Exit
    }
    
    # Transfer smtp configuration:
    try {
        if ($mail -or $transferAll) {

            $objectSimpleConfig = $null
            $objectSimpleConfig = fnTransferSimpleConfig $sourceInstance $sourceSession $targetInstance $targetSession $overwrite "Mail" "POST" "api/mail"

            if ($objectSimpleConfig) {
                write-host "Transferring SMTP configuration finished."
            }
        }
    }
    catch {
        write-host "Unable to transfer SMTP configuration due to:" -ForegroundColor Red
        write-host "$_.Exception.Message"
    
        Exit
    }
        
    # Transfer ldap configuration:
    try {
        if ($ldap -or $transferAll) {

            $objectSimpleConfig = $null
            $objectSimpleConfig = fnTransferSimpleConfig $sourceInstance $sourceSession $targetInstance $targetSession $overwrite "LDAP" "POST" "api/usermanagement/ldap/config"

            if ($objectSimpleConfig) {
                write-host "Transferring LDAP configuration finished."
            }

        }
    }
    catch {
        write-host "Unable to transfer LDAP configuration due to:" -ForegroundColor Red
        write-host "$_.Exception.Message"
    
        Exit
    }

    # Transfer Indexer configuration:
    # This is still work in progress, so this function is not yet available.
    <#
    try {
        if ($indexer -or $transferAll) {

            # Stop Indexer in target instance:
            $result = $null
            $result = fnStopIndexer $targetInstance $targetSession

            if ($result) {
                $objectSimpleConfig = $null
                $objectSimpleConfig = fnTransferSimpleConfig $sourceInstance $sourceSession $targetInstance $targetSession $overwrite "INDEXER" "PUT" "api/indexer/connection"

                if ($objectSimpleConfig) {
                    write-host "Transferring Indexer configuration finished."
                }
            }
        }
    }
    catch {
        write-host "Unable to transfer Indexer configuration due to:" -ForegroundColor Red
        write-host "$_.Exception.Message"
    
        Exit
    }
    #>

    # Transfer Argos configuration:
    try {
        if ($argos -or $transferAll) {

            # Transfer settings configuration:
            $objectArgosSettingsConfig = fnTransferSimpleConfig $sourceInstance $sourceSession $targetInstance $targetSession $overwrite "ARGOS" "POST" "api/metrics/configuration/settings"

            # Transfer subagent configuration:
            $objectArgosSubagentConfig = fnTransferSimpleConfig $sourceInstance $sourceSession $targetInstance $targetSession $overwrite "ARGOS" "POST" "api/metrics/configuration/subagent"

            if ($objectArgosSettingsConfig -and $objectArgosSubagentConfig) {
                write-host "Transferring Argos configuration finished."
            }
        }
    }
    catch {
        write-host "Unable to transfer Argos configuration due to:" -ForegroundColor Red
        write-host "$_.Exception.Message"
    
        Exit
    }

    # Transfer users and roles and their assignments:
    try {
        if ($user -or $transferAll) {

            # Transfer roles:
            $sourceRolesObject = $null
            $sourceRolesObject = fnTransferRoles $sourceInstance $sourceSession $targetInstance $targetSession $overwrite

            # Transfer users:
            $sourceUsersObject = $null
            $sourceUsersObject = fnTransferUsers $sourceInstance $sourceSession $targetInstance $targetSession $overwrite

            # Transfer Users/Roles assignment:
            $result = $null
            $result = fnTransferUsersRoles $sourceInstance $sourceSession $targetInstance $targetSession $overwrite $sourceRolesObject

            if ($sourceRolesObject -and $sourceUsersObject -and $result) {
                write-host "Transferring user accounts and roles finished."
            }
        }
    }
    catch {
        write-host "Unable to transfer user/roles due to:" -ForegroundColor Red
        write-host "$_.Exception.Message"
    
        Exit
    }

    # Transfer basic coniguration of instance:
    try {
        if ($config -or $transferAll) {

            # Tranfer config:
            $result = $null
            $result = fnTransferConfig $sourceInstance $sourceSession $targetInstance $targetSession $overwrite

            if ($result) {
                write-host "Transferring basic configuration of instance finished."
            }
        }
    }
    catch {
        write-host "Unable to transfer basic instance configuration due to:" -ForegroundColor Red
        write-host "$_.Exception.Message"
    
        Exit
    }

    # Transfer object privileges:
    try {
        if ($objectPrivilege -or $transferAll) {

            # Get all roles from target instance. 
            # Store result in variable "$targetRolesBasicObject", which is of local scope of this script for usage in fnSetDomainObjectPriv
            $targetRolesBasicObject = fnCallRestApi "GET" $reqHeader "application/json" $null "$targetInstance/api/usermanagement/roles/basic" $targetSession

            # Set "objectPath" to value of argument "objectPrivilege":
            $objectPath = $domainObjectPath

            # Get domain object(s) from source instance:
            if ($objectPath -eq ">") {
                # Get domain object list from root element:
                $srcDomainObjectList = fnGetDomainObjectListByPath $sourceInstance $sourceSession $objectPath

                # Loop through list of domain objects on root level and transfer privileges:
                Foreach ($srcDO in $srcDomainObjectList) 
                {
                    $result = fnTransferDomainObjectPrivs $sourceInstance $sourceSession $targetInstance $targetSession $($srcDO.objectPath) $overwrite
                }
            }
            else {
                $result = fnTransferDomainObjectPrivs $sourceInstance $sourceSession $targetInstance $targetSession $objectPath $overwrite
            }

            if ($result) {
                write-host "Transferring object privileges finished."
            }
        }
    }
    catch {
        write-host "Unable to transfer object privileges due to:" -ForegroundColor Red
        write-host "$_.Exception.Message"
    
        Exit
    }

    # Transfer system privileges:
    try {
        if ($systemPrivilege -or $transferAll) {

            $result = fnTransferSystemPrivs $sourceInstance $sourceSession $targetInstance $targetSession

            if ($result) {
                write-host "Transferring system privileges finished."
            }
        }
    }
    catch {
        write-host "Unable to transfer system privileges due to:" -ForegroundColor Red
        write-host "$_.Exception.Message"
    
        Exit
    }


}
