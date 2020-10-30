# h2-maintenance.ps1
Rebuilds H2 database of an nJAMS Server instance.

## Description:

This maintenance script rebuilds the nJAMS H2 database. Unused space will be released and the indexes are re-created. The script can be executed on a Windows, Linux, or Mac machine.

## How it works:

First the script exports the nJAMS H2 database file `njams.mv.db` into a temporary ZIP file. Secondly a new H2 database file is created based on the export.

There are basically two options to use the script.

### Manual approach:

  1. Copy the script to a working folder of a Windows, Linux or Mac machine that has sufficient free disk space and has installed Java 8 or higher.
  2. Shutdown nJAMS Server.
  3. Copy `njams.mv.db` from `<njams-installation>/data/h2/` of your nJAMS Server machine to the working folder of this machine.
  4. Copy H2 JDBC driver jar file from `<njams-installation>/wildfly16/modules/system/layers/base/com/h2database/h2/main/` of your nJAMS Server machine to the working folder.
  5. Open Powershell and CD to the working folder.
  6. Run the script. If applicable, enter the credentials to access nJAMS H2 database by specifying parameters `-username` and `-password`. The new nJAMS H2 database is created in subfolder `target` of your working folder. You will notice, the new file is significantly smaller than the original file.
  7. Replace the original nJAMS H2 database file on nJAMS Server machine with the newly created H2 database file.
  8. Restart nJAMS Server.

### Automatic approach:

  1. Copy the script to a working folder of your nJAMS Server machine. Make sure this machine has sufficient free disk space and has installed Java 8 or higher.
  2. Shutdown nJAMS Server.
  3. Open Powershell and CD to the working folder.
  4. Run the script. Specify credentials to H2 database and specify the path to your nJAMS installation, e,g, `/opt/njams/`. The script copies H2 database file and JDBC driver file from nJAMS installation folder to working folder and replaces the original H2 database file with the newly created file. 
  5. Restart nJAMS Server.

## Characteristics:

* shrinks nJAMS H2 database by rebuilding H2 database file
* supports H2 database files of nJAMS Server 5.x
* runs on Windows, Linux, and macOS using PowerShell Core 7 or Windows PowerShell 5

## Usage:

```
SYNTAX
    ./h2-maintenance.ps1 [[-dbUser] <String>] [[-password] <String>]
                      [[-dbName] <String>]
                      [[-njamsDir] <String>]
                      [[-workingDir] <String>]
                      [-force]
                      [<CommonParameters>]
```

Run `./h2-maintenance.ps1 -?` to learn more about how to use the script. 

Run `help ./h2-maintenance.ps1 -examples` to learn from some common examples. 

## Execution:

* Linux/Unix:

  Run a shell and enter command, for example:

  ```
  $ pwsh -c './h2-maintenance.ps1 -dbUser "admin" -password "admin"'
  ```

* Windows:

  Run PowerShell and enter command, for example:

  ```
  PS C:\> .\h2-maintenance.ps1 -dbUser "admin" -password "admin"
  ```

* macOS:

  Run a shell and enter command, for example:

  ```
  $ pwsh -c './h2-maintenance.ps1 -dbUser "admin" -password "admin"'
  ```

## Prerequisites:

* General requirements:

  - Java 8 or higher is required
  - Make sure there is enough disk space available on the machine, where you execute the script. 
  - You need read/write permission on working directory
  - If applicable, you need read/write permission on nJAMS installation directory

* Linux/Unix: 

  This script requires *PowerShell 7* or higher. Please follow these instructions to install PowerShell 7 on Linux/Unix:
  https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7

* Windows:

  This script requires *Windows PowerShell 5*, respectively *PowerShell 7* or higher. Please follow these instructions to install PowerShell 7 on Linux/Unix:
  https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-windows?view=powershell-7

* macOS:

  This script requires *PowerShell 7* or higher. Please follow these instructions to install PowerShell 7 on macOS:
  https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-macos?view=powershell-7