# bulkReplay
Script for replaying process executions by configuration using Replay Command line tool.

## Description:

Replay Command line tool allows to query for process executions in a given nJAMS instance and to replay these exections. This script provides a configuration file to query and replay process executions in a more convenient way.


## How it works:

This script reads the content of the configuration file "replay.properties", queries for process executions in the specified nJAMS instance according to the given search criteria, and replays the found entries in the same nJAMS instance.


## Requirements:

  - Java 11 or higher is required
  - PowerShell is required, see prerequisites below
  - Make sure there is enough disk space available on the machine, where you execute the script. 
  - You need read/write permission on working directory


## Usage:

1. Copy the content of this repository to a folder on your machine
2. Edit "replay.properties" file according to your needs
3. Execute this script

```
SYNTAX
    ./bulkReplay.ps1 [-query]
                      [-replay]
                      [-test] 
                      [[-propertyFile] <filename>] 
                      [<CommonParameters>]
```

Run `./bulkReport.ps1 -?` to learn more about how to use the script. 


## Execution:

* Linux/Unix:

  Run a shell and enter command, for example:

  ```
  $ pwsh -c './bulkReplay.ps1 -query -replay'
  ```

* Windows:

  Run PowerShell and enter command, for example:

  ```
  PS C:\> .\bulkReplay.ps1 -query -replay
  ```

* macOS:

  Run a shell and enter command, for example:

  ```
  $ pwsh -c './bulkReplay.ps1 -query -replay'
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