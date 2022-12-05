# njams_agent.ps1
Script to start/stop nJAMS Agent on Linux or Windows machines.

## Description:

nJAMS Agent collects metrics from this machine and sends these metrics to a dedicated nJAMS instance.
This script starts and stops nJAMS Agent based on the configuration in `<njams-agent-home>/config` by default.
Before you run this script, nJAMS Agent should be configured. Edit 'njams_agent.conf', respectively 'njams_agent_windows.conf', and configure input and output plugins.
Please refer to https://docs.integrationmatters.com/projects/agent for more information.

This script runs on Linux and macOS using PowerShell 7 as well as on Windows using Windows PowerShell 5 or PowerShell 7.


## How it works:

This script requires an existing installation of nJAMS Agent 4.1 or higher and replaces the existing scripts 'njams_agent.sh' (Linux) and 'start_exe.bat', 'service.cmd', 'uninstall_daemon.cmd' 'start_daemon.cmd', 'stop_daemon.cmd' (Windows) by a universal PowerShell script.


## Requirements:

  - nJAMS Agent 4.1 or higher is required
  - PowerShell is required, see prerequisites below
  - In case you are using TIBCO EMS input/output plugin, make sure TIBCO EMS libs are available in classpath on this machine.


## Setup:

1. Copy 'njams_agent.ps1' into nJAMS Agent's bin folder: `<njams-agent-home>/bin`.
2. Edit 'njams_agent.conf', respectively 'njams_agent_windows.conf', in `<njams-agent-home>/config` according to your needs
3. Run this script

```
SYNTAX
    ./njams_agent.ps1 [-status]
                      [-start]
                      [-stop] 
                      [-restart]
                      [-service]
                      [-install]
                      [-uninstall]
                      [<CommonParameters>]
```

Run `./njams_agent.ps1 -?` to learn more about how to use the script. 


## Execution:

* Linux/Unix:

  Run a shell and enter command, for example:

  ```
  $ pwsh -c './njams_agent.ps1 -start'
  ```

* Windows:

  Run PowerShell and enter command, for example:

  ```
  PS C:\> .\njams_agent.ps1 -start
  ```

* macOS:

  Run a shell and enter command, for example:

  ```
  $ pwsh -c './njams_agent.ps1 -start'
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