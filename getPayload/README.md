# getPayload

Outputs payload data into files from activities of process executions of a given process and a period of time.

## Description:

This script outputs the payload data into files from activities of process executions monitored with nJAMS. The script searches for a particular process name and a given period of time and outputs the payload data of any activity of the process execution.


## How it works:

This script authenticates against a given nJAMS instance and searches for process executions of a specified period of time. For each process execution the payload data of any activity will be written into individual files of the current directory.


## Requirements:

  - PowerShell is required, see prerequisites below
  - You need read/write permission on working directory


## Usage:

```
SYNTAX
    ./getPayload.ps1 [-instance] <String> 
                      [-username] <String> [-password] <String> 
                      [-process] <String> 
                      [-from] <String>] 
                      [-to] <String> 
                      [<CommonParameters>]
```

Run `./getPayload.ps1 -?` to learn more about how to use the script. 


## Execution:

* Linux/Unix:

  Run a shell and enter command, for example:

  ```
  $ pwsh -c './getPayload.ps1 -instance "http://vslnjams03:38080/njams" -user "admin" -password "admin" -from "2022-10-10T08:00:00.000" -to "2022-10-10T12:00:00.000" -process "DispatcherService.process"'
  ```

* Windows:

  Run PowerShell and enter command, for example:

  ```
  PS C:\> .\getPayload.ps1 -instance "http://vslnjams03:38080/njams" -user "admin" -password "admin" -from "2022-10-10T08:00:00.000" -to "2022-10-10T12:00:00.000" -process "DispatcherService.process"
  ```

* macOS:

  Run a shell and enter command, for example:

  ```
  $ pwsh -c './getPayload.ps1 -instance "http://vslnjams03:38080/njams" -user "admin" -password "admin" -from "2022-10-10T08:00:00.000" -to "2022-10-10T12:00:00.000" -process "DispatcherService.process"'
  ```

## Prerequisites:

* Linux/Unix: 

  This script requires *PowerShell 7* or higher. Please follow these instructions to install PowerShell 7 on Linux/Unix:
  https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7

* Windows:

  This script requires *Windows PowerShell 5*, respectively *PowerShell 7* or higher. Please follow these instructions to install PowerShell 7 on Linux/Unix:
  https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7

* macOS:

  This script requires *PowerShell 7* or higher. Please follow these instructions to install PowerShell 7 on macOS:
  https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7