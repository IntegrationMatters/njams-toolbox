## findDomainObjects.ps1
Find domain objects of given nJAMS instance. 

## Description:

This script browses the domain objects of an nJAMS Server instance. 

You can enter various filter criteria such as settings for retention or loglevel, as well as properties like nJAMS Client version number. Especially in large nJAMS instances with thousands of domain objects 'findDomainObjects' helps you to detect misconfigurations of domain objects and outdated versions of nJAMS Clients. If you omit any filter criteria, the script provides a list of all domain objects of the nJAMS instance.

The script can be executed on any Linux/Unix, Windows, or Mac machine within the same network of the machine, where nJAMS Server is running.

## Characteristics:

* find domain objects of an nJAMS instance
* filter domain objects by common settings such as 'retention', 'stripOnSuccess', or by process or client properties like 'logLevel', 'exclude', 'logMode', 'version' of nJAMS Clients, etc.
* allows RegEx in filter criteria for precise hits
* supports nJAMS Server instances 4.4, 5.0, and 5.1 using HTTP or TLS/HTTPS.
* script runs on Linux and macOS using Powershell 7 or on Windows using Windows PowerShell 5 or PowerShell 7
* output can be formatted individually by common PowerShell `format` cmdlet

## Usage:

```
SYNTAX
    ./findDomainObjects.ps1 [-instance] <String>
                            [-username] <String> [-password] <String>
                            [[-versionNumber] <String>] 
                            [[-sdkVersion] <String>] 
                            [[-logMode] <String>] 
                            [[-machineName] <String>] 
                            [[-logLevel] <String>] 
                            [[-exclude] <String>] 
                            [[-name] <String>] 
                            [[-category] <String>] 
                            [[-stripOnSuccess] <String>] 
                            [[-retention] <String>] 
                            [[-parentId] <Int32>]
                            [<CommonParameters>]
```

Run `./findDomainObjects.ps1 -?` to learn more about how to use the script. 

## Execution:

* Linux/Unix:

  Run a shell and enter command, for example:

  ```
  $ pwsh -c './findDomainObjects.ps1 -instance "http://localhost:8080/njams" -logLevel "ERROR" | format-table'
  ```

* Windows:

  Run PowerShell and enter command, for example:

  ```
  PS C:\> .\findDomainObjects.ps1 -instance "http://localhost:8080/njams" -logLevel "ERROR" | format-table"
  ```

* macOS:

  Run a shell and enter command, for example:

  ```
  $ pwsh -c './findDomainObjects.ps1 -instance "http://localhost:8080/njams" -logLevel "ERROR" | format-table'
  ```

## Prerequisites:

* Linux/Unix: 

  This script requires *PowerShell 7* or higher. Please follow these instructions to install PowerShell 7 on Linux/Unix:
  https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7

* Windows:

  This script requires *Windows PowerShell 5*, respectively *PowerShell 7* or higher. Please follow these instructions to install PowerShell 7 on Linux/Unix:
  https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7

* macOS:

  This script requires *PowerShell 7* or higher. Please follow these instructions to install Powershell 7 on macOS:
  https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powerShell-7