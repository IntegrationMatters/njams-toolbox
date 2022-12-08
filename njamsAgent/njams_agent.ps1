<#
.SYNOPSIS
    Starts / stops nJAMS Agent on this machine.

.DESCRIPTION
    nJAMS Agent collects metrics from this machine and sends these metrics to a dedicated nJAMS instance.
    This script starts and stops nJAMS Agent based on the configuration in '<njams-agent-home>/config' by default.
    Before you run this script, nJAMS Agent should be configured. Edit 'njams_agent.conf', respectively 'njams_agent_windows.conf', and configure input and output plugins.
    Please refer to https://docs.integrationmatters.com/projects/agent for more information.

    This script runs on Linux and macOS using PowerShell 7 as well as on Windows using Windows PowerShell 5 or PowerShell 7.

    Please note:
    In case you are using TIBCO EMS output plugin, make sure TIBCO EMS libs are available in classpath on this machine.

.PARAMETER start
    Starts a process instance of nJAMS Agent. There will be no start, if a running instance of nJAMS Agent is detected.
    Can be used with additional option '-service' to start nJAMS Agent Windows Service.

.PARAMETER stop
    Stops the process instance of nJAMS Agent. 
    Can be used with additional option '-service' to stop nJAMS Agent Windows Service.

.PARAMETER restart
    Restart process instance of nJAMS Agent. 
    Can be used with additional option '-service' to restart nJAMS Agent Windows Service.

.PARAMETER status
    Shows the status of nJAMS Agent, whether process instance is running or stopped.
    Can be used with additional option '-service' to show the current status of nJAMS Agent Windows Service.

.PARAMETER service
    This option is used to run nJAMS Agent as Windows Service and can only be used on Windows systems.
    The following parameters can be used in connection with this option: -start, -restart, -stop, -status, -install, -uninstall.

.PARAMETER install
    Installs nJAMS Agent as Windows Service. Requires elevated user privilege and can only be used on Windows systems. 
    
.PARAMETER uninstall
    Uninstalls nJAMS Agent Windows Service. Requires elevated user privilege and can only be used on Windows systems.

.PARAMETER configFile
    References a full path to the nJAMS Agent config file. If this parameter is not specified, the default config file for Linux, respectively Windows, is used.

.EXAMPLE
    ./njams_agent.ps1 -start
    Starts an process instance of nJAMS Agent.
    
.EXAMPLE
    ./njams_agent.ps1 -service -start
    Starts nJAMS Agent Windows Service.
    
.EXAMPLE
    ./njams_agent.ps1 -stop
    Stops the particular process instance of nJAMS Agent that has been started before with this script.

.EXAMPLE
    ./njams_agent.ps1 -restart
    Restarts process instance of nJAMS Agent.

.EXAMPLE
    ./njams_agent.ps1 -status
    Shows the running status of this instance of nJAMS Agent.
	
.EXAMPLE
    ./njams_agent.ps1 -service -status
    Shows the status of nJAMS Agent Windows Service.
	
.EXAMPLE
    ./njams_agent.ps1 -start -config "/opt/njams/agent/config/njams_agent_https.conf"
    Start nJAMS Agent using config file 'njams_agent_https.conf'.
	
.LINK
    https://docs.integrationmatters.com/projects/agent
    https://www.integrationmatters.com/

.NOTES
    Copyright: (c) 2021, 2022 Integration Matters
#>

param(
    [switch]$start,
    [switch]$restart,
    [switch]$stop,
    [switch]$status,
    [switch]$service,
    [switch]$install,
    [switch]$uninstall,
    [string]$configFile
)

# Change globals here, if required:
$defaultConfig = "njams_agent.conf"
$agentBin = "njams_agent"
$pwshCmd = "pwsh"

# Check runtime env. On PS Core $IsWindows is set automatically.
if ($PSVersionTable.PSEdition -ne "Core") {
    $IsWindows = $True
    $pwshCmd = "powershell"
}

# For Windows systems set corresponding config for nJAMS Agent:
if ($IsWindows) {
    $defaultConfig = "njams_agent_windows.conf"
    $agentBin = "njams_agent.exe"
}

# Use specified or default config file:
if ($configFile) {
    $agentConfig = $configFile
}
else {
    $agentConfig = "$PSScriptRoot/../config/$defaultConfig"
}

# For using TIBCO EMS input/output plugin, make sure TIBCO EMS Client libs are installed on this machine and are available in classpath.
if ($IsWindows) {
    # Option 1: Add <TIBCO_HOME>\ems\<VERSION>\bin to User Variable 'path':
    #   $EMS_HOME = "C:\TIBCO\ems\10.1"
    #   if (($env:path -like "*" + $EMS_HOME + "\bin*") -eq $False) {
    #       $env:path += ";" + $EMS_HOME + "\bin"
    #   }
    # Option 2: Add TIBCO EMS bin path to System Variable 'path'. Use this option, if you want to start nJAMS Agent as Windows Service.
}
if ($IsLinux) {
    # On Linux set $env:LD_LIBRARY_PATH to TIBCO EMS Client libs path.
    # Option 1: Copy TIBCO EMS Client libs from '<TIBCO_HOME>/ems/<VERSION>/lib' to '<njams-agent-home>/lib' and refer to this location:
    #   $EMS_LIBS = "$PSScriptRoot/../lib/64:$PSScriptRoot/../lib"
    # Option 2: Refer to TIBCO EMS Client libs path on this machine:
    #   $EMS_HOME = "/opt/tibco/ems/8.6"
    #   $EMS_LIBS = "$EMS_HOME/lib/64:$EMS_HOME/lib"
    # Set $env_LD_LIBRARY_PATH:
    #   if (($env:LD_LIBRARY_PATH -like "*" + $EMS_LIBS + "*") -eq $False) {
    #       $env:LD_LIBRARY_PATH += ":" + $EMS_LIBS
    #   } 
}

# Present help, when no paramater is specified:
if ($PSBoundParameters.Count -eq 0) {

    write-output " "
    write-output "nJAMS Agent collects metrics from this machine and sends these metrics to a dedicated nJAMS instance."
    write-output "Type '$PSScriptRoot/njams_agent.ps1 -start' to start nJAMS Agent process instance."
    write-output "Or type '$PSScriptRoot/njams_agent.ps1 -?' to get more information."
    write-output " "
}

# Start nJAMS Agent:
if ($PSBoundParameters.ContainsKey('start') -eq $True) {

    if ($PSBoundParameters.ContainsKey('service') -eq $True -and $IsWindows) {
        # Start Windows Service of nJAMS Agent:
        # Check for existing Windows Service, before starting the service:
        $serviceObject = Get-Service -name "njams_agent"  -ErrorAction SilentlyContinue

        if ($serviceObject) {
            if ([string]$serviceObject.Status -eq 'stopped' -and [string]$serviceObject.starttype -ne 'disabled') {

                write-output "Starting nJAMS Agent Windows Service..."

                write-output $(get-date -format "yyyy-MM-dd HH:mm:ss.fff") | out-file $PSScriptRoot/../log/console.log -Append
                $arguments = "& start-service -name njams_agent -PassThru | Format-List >> $PSScriptRoot/../log/console.log"
                start-process -FilePath $pwshCmd -Verb runAs -ArgumentList "-c", $arguments
        
                write-output "Verify start of service using './njams_agent.ps1 -service -status' or check <njams_agent_home>/log/console.log"
                write-output " "
            }
            else {

                write-output "nJAMS Agent Windows Service is not starting up, current status/starttype is '$($serviceObject.status)/$($serviceObject.starttype)'."
                write-output " "
            }
        }
        else {

            write-output "nJAMS Agent Windows Service is not installed. Please install nJAMS Agent Windows Service using option '-install' before starting the service."
            write-output " "
        }
    }
    else {
        # Start process instance of nJAMS Agent.
        # Check for existing nJAMS Agent process, before starting up:"
        $procId = Get-Content $PSScriptRoot/../njams_agent.pid -ErrorAction SilentlyContinue

        if ($procId) {

            $processObject = Get-Process -id $procId -ErrorAction SilentlyContinue

            if ($($processObject.ProcessName) -eq "njams_agent") {

                write-output "nJAMS Agent already running on this machine, pid is $procId"
                write-output " "

                Exit
            }
        }

        write-output "Starting nJAMS Agent..."

#        $processObject = Start-Process -NoNewWindow -FilePath "$PSScriptRoot/$agentBin" -PassThru -ArgumentList "--config $agentConfig" -RedirectStandardError "$PSScriptRoot/../log/console.log"
        $processObject = Start-Process -FilePath "$PSScriptRoot/$agentBin" -PassThru -ArgumentList "--config $agentConfig" -RedirectStandardError "$PSScriptRoot/../log/console.log"

        if ($processObject) {

            # Save pid into file:
            write-output $processObject.id > $PSScriptRoot/../njams_agent.pid
        }

        write-output "nJAMS Agent pid is $($processObject.id)."
        write-output " "
    }
}

# Stop nJAMS Agent:
if ($PSBoundParameters.ContainsKey('stop') -eq $True) {

    if ($PSBoundParameters.ContainsKey('service') -eq $True -and $IsWindows) {
        # Stop Windows Service of nJAMS Agent.
        # Check for existing Windows Service, before stopping the service:
        $serviceObject = Get-Service -name "njams_agent"  -ErrorAction SilentlyContinue

        if ($serviceObject) {
            if ([string]$serviceObject.Status -eq 'running') {

                write-output "Stopping nJAMS Agent Windows Service..."

                write-output $(get-date -format "yyyy-MM-dd HH:mm:ss.fff") | out-file $PSScriptRoot/../log/console.log -Append
                $arguments = "& stop-service -name njams_agent -PassThru | Format-List >> $PSScriptRoot/../log\console.log"
                start-process -FilePath $pwshCmd -Verb runAs -ArgumentList "-c", $arguments
            
                write-output "Verify stop of service using './njams_agent.ps1 -service -status' or check <njams_agent_home>/log/console.log"
                write-output " "
            }
            else {

                write-output "nJAMS Agent Windows Service is not going to stop, current status/starttype is '$($serviceObject.status)/$($serviceObject.starttype)'."
                write-output " "
            }
        }
        else {

            write-output "nJAMS Agent Windows Service is not installed, no stopping. You can use option '-install' to install nJAMS Agent Windows Service."
            write-output " "
        }
    }
    else {
        # Stop process instance of nJAMS Agent.
        # Check for existing nJAMS Agent process"
        $procId = Get-Content $PSScriptRoot/../njams_agent.pid -ErrorAction SilentlyContinue

        if ($procId) {

            $processObject = Get-Process -id $procId -ErrorAction SilentlyContinue

            if ($($processObject.ProcessName) -eq "njams_agent") {
        
                write-output "Stopping nJAMS Agent at pid $procId ..."

                stop-process -id $procId

                # Wait a bit before before verifying the process is stopped:
                Start-Sleep -Seconds 2

                # Make sure nJAMS Agent process has terminated successfully:
                if (get-process -id $procId -ErrorAction SilentlyContinue) {
        
                    # Force nJAMS Agent process to stop:
                    stop-process -id $procId -Force -ErrorAction SilentlyContinue
                }

                write-output "nJAMS Agent stopped."
                write-output " "
        
                Exit
            }
            else {

                write-output "nJAMS Agent process already stopped at pid $procId"
                write-output " "

                Exit
            }
        }

        write-output "nJAMS Agent is not running, no stop required."
        write-output " "
    }
}

# Restart nJAMS Agent process:
if ($PSBoundParameters.ContainsKey('restart') -eq $True) {
    if ($PSBoundParameters.ContainsKey('service') -eq $True -and $IsWindows) {
        # Restart Windows Service of nJAMS Agent.
        # Check for existing Windows Service, before stopping/starting the service:
        $serviceObject = Get-Service -name "njams_agent" -ErrorAction SilentlyContinue

        if ($serviceObject) {
            if ([string]$serviceObject.starttype -ne 'disabled') {

                write-output "Going to restart nJAMS Agent Windows Service now."

                # Stop:
                if ([string]$serviceObject.Status -ne 'stopped') {
                    write-output "Stop nJAMS Agent Windows Service..."

                    write-output $(get-date -format "yyyy-MM-dd HH:mm:ss.fff") | out-file $PSScriptRoot/../log/console.log -Append
                    $arguments = "& stop-service -name njams_agent -PassThru | Format-List >> $PSScriptRoot/../log/console.log"
                    start-process -FilePath $pwshCmd -Verb runAs -ArgumentList "-c", $arguments
                }

                # Wait some seconds before starting again:
                Start-Sleep -Seconds 5

                # Start:
                $serviceObject = Get-Service -name "njams_agent" -ErrorAction SilentlyContinue
                if ([string]$serviceObject.Status -eq 'stopped') {
                    write-output "Start nJAMS Agent Windows Service..."

                    write-output $(get-date -format "yyyy-MM-dd HH:mm:ss.fff") | out-file $PSScriptRoot/../log/console.log -Append
                    $arguments = "& start-service -name njams_agent -PassThru | Format-List >> $PSScriptRoot/../log/console.log"
                    start-process -FilePath $pwshCmd -Verb runAs -ArgumentList "-c", $arguments

                    write-output "Verify restart of service using './njams_agent.ps1 -service -status' or check <njams_agent_home>/log/console.log"
                    write-output " "
                }
                else {

                    write-output "Restarting nJAMS Agent Windows Service failed, current status/starttype is '$($serviceObject.status)/$($serviceObject.starttype)'."
                    write-output " "
                }
            }
            else {

                write-output "nJAMS Agent Windows Service is not going to restart, current status/starttype is '$($serviceObject.status)/$($serviceObject.starttype)'."
                write-output " "
            }
        }
        else {

            write-output "nJAMS Agent Windows Service is not installed, no restarting. You can use option '-install' to install nJAMS Agent Windows Service."
            write-output " "
        }
    }
    else {

        write-output "Going to restart nJAMS Agent..."

        # Restart process instance of nJAMS Agent
        # Check for existing nJAMS Agent process:"
        $procId = Get-Content $PSScriptRoot/../njams_agent.pid -ErrorAction SilentlyContinue

        if ($procId) {

            $processObject = Get-Process -id $procId -ErrorAction SilentlyContinue

            if ($($processObject.ProcessName) -eq "njams_agent") {
        
                write-output "Stopping nJAMS Agent at pid $procId ..."

                stop-process -id $procId

                # Make sure nJAMS Agent process has terminated successfully:
                if (get-process -id $procId -ErrorAction SilentlyContinue) {
        
                    # Force nJAMS Agent process to stop:
                    stop-process -id $procId -Force
                }

                write-output "nJAMS Agent stopped."
                write-output " "
            }
        }

        write-output "Starting nJAMS Agent..."

        $processObject = Start-Process -NoNewWindow -FilePath "$PSScriptRoot/$agentBin" -PassThru -ArgumentList "--config $agentConfig" -RedirectStandardError "$PSScriptRoot/../log/console.log"

        if ($processObject) {

            write-output $processObject.id > $PSScriptRoot/../njams_agent.pid
        }

        write-output "nJAMS Agent pid is $($processObject.id)."
        write-output " "
    }
}

# Show status of nJAMS Agent:
if ($PSBoundParameters.ContainsKey('status') -eq $True) {

    if ($PSBoundParameters.ContainsKey('service') -eq $True -and $IsWindows) {
        # Show status of nJAMS Agent Windows Service
        # Check for existing Windows Service, before stopping/starting the service:
        $serviceObject = Get-Service -name "njams_agent" -ErrorAction SilentlyContinue

        if ($serviceObject) {

            Get-Service -name njams_agent | select-object -property status, starttype, name, displayname | Format-List
        }
        else {

            write-output "nJAMS Agent Windows Service is not installed. You can use option '-install' to install nJAMS Agent Windows Service."
            write-output " "
        }
    }
    else {
        # Check for existing nJAMS Agent process, before starting up:"
        $procId = Get-Content $PSScriptRoot/../njams_agent.pid -ErrorAction SilentlyContinue

        if ($procId) {

            $processObject = Get-Process -id $procId -ErrorAction SilentlyContinue

            if ($($processObject.ProcessName) -eq "njams_agent") {
        
                write-output "nJAMS Agent is running."
                write-output $processObject | select-object id, name | Format-List
            }
            else {

                write-output "nJAMS Agent process stopped at pid $procId"
                write-output " "
            }

            Exit
        }
        else {

            write-output "nJAMS Agent is not running."
            write-output " "
        }
    }
}
# Uninstall nJAMS Agent Windows Service:
if ($PSBoundParameters.ContainsKey('uninstall') -eq $True -and $IsWindows) {

    # Check, if Windows Service exists:
    $serviceObject = Get-Service -name "njams_agent" -ErrorAction SilentlyContinue

    if ($serviceObject) {

        if ([string]$serviceObject.Status -eq 'stopped') {

            write-output "Uninstalling nJAMS Agent Windows Service..."
            
            $arguments = "& $PSScriptRoot/$agentBin --service uninstall"
            start-process -FilePath $pwshCmd -Verb runAs -ArgumentList "-c", $arguments

            write-output "nJAMS Agent Windows Service uninstalled."
            write-output " "

        }
        else {

            write-output "nJAMS Agent Windows Service is currently running. Please stop service, before uninstalling."
            write-output "To stop service use './njams_agent.ps1 -service -stop'"
            write-output " "
        }
    }
    else {

        write-output "nJAMS Agent Windows Service does not exist, no uninstall."
        write-output " "
    }
}

# Install nJAMS Agent Windows Service:
if ($PSBoundParameters.ContainsKey('install') -eq $True -and $IsWindows) {

    # Check, if Windows Service exists:
    $serviceObject = Get-Service -name "njams_agent" -ErrorAction SilentlyContinue

    if (!$serviceObject) {
    
        write-output "Installing nJAMS Agent Windows Service..."
        
        $arguments = "& $PSScriptRoot/$agentBin --service install --config $agentConfig --config-directory $PSScriptRoot/../config/njams_agent.d"
        start-process -FilePath $pwshCmd -Verb runAs -ArgumentList "-c", $arguments

        write-output "nJAMS Agent Windows Service installed."
        write-output " "

    }
    else {

        write-output "nJAMS Agent Windows Service already exists, no install."
        write-output " "
    }
}
