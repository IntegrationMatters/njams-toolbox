# transferInstanceConfig.ps1
Transfers configuration from source nJAMS instance to target nJAMS instance.

## Description:

This script transfers the configuration settings from a given source nJAMS instance to a given target nJAMS instance. This tool might be useful, if you want to create a new nJAMS instance based on the same settings of an existing nJAMS instance.

You can specify individual configurations to transfer.

The following configurations can be transfered:

* **config** - basic settings of an nJAMS Server instance such as name of instance, search options, retention settings, etc.
* **ldap** - settings of a LDAP configuration
* **dataProvider** - settings of Data Providers including JMS and JNDI configurations
* **mail** - settings of a smtp server
* **argos** - settings of Argos configuration
* **indexer** - settings of the Indexer configuration
* **user** - user accounts and roles including assignments

If you do not specify a particular configuration, all configurations are transferred to the target nJAMS instance.
The script outputs the transferred configurations.
The script can be executed on any Linux/Unix, Windows, or Mac machine within the same network of the machine, where the source and target nJAMS Server instances are running.

  **Please note:**
  Passwords are transfered encrypted from source instance. That means the transferred passwords cannot be decrypted by the target instance and are therefore invalid!
  There are two options with regards to passwords:
  1. You have to reset the passwords later in the target instance
  2. Another option is to replace ´keyfile.bin´ of target instance with ´keyfile.bin´ from source instance. 
      ´keyfile.bin´ is used to encrypt/decrypt passwords and can just be copied from the source machine to the target machine. 
      The keyfile usually resides in ´<njams-installation-dir>/data´. 
      Restart target nJAMS instance afterwards and the target instance is now able to decrypt the transferred passwords.
  
  Exception:
  Passwords of nJAMS user accounts are NOT transferred. 

## Characteristics:

* transfers all or particular configurations from a source instance to a target instance
* supports nJAMS Server instances 4.4, 5.0, and 5.1 using HTTP or TLS/HTTPS
* script runs on Linux and macOS using PowerShell 7 or on Windows using Windows PowerShell 5 or PoweShell 7

## Preparation:

* Source and target nJAMS instances must be up and running
* Specified user accounts for source and target instances must be of role 'admin'. 
* Double check if the target instance is correct and its configuration may be modified.

## Usage:

```
SYNTAX
    ./transferInstanceConfig.ps1  [-sourceInstance] <String> 
                                  [-sourceUsername] <String> [-sourcePassword] <String> 
                                  [-targetInstance] <String>
                                  [-targetUsername] <String> [-targetPassword] <String> 
                                  [[-overwrite]]
                                  [[-argos]]
                                  [[-config]]
                                  [[-dataProvider]]
                                  [[-indexer]]
                                  [[-ldap]]
                                  [[-mail]]
                                  [[-user]]
                                  [<CommonParameters>]
```

Run `./transferInstanceConfig.ps1 -?` to learn more about how to use the script. 

## Execution:

* Linux/Unix:

  Run a shell and enter command, for example:

  ```
  $ pwsh -c './transferInstanceConfig.ps1 -sourceInstance "http://source_machine:8080/njams" -targetInstance "http://target_machine:8080/njams" -dataProvider'
  ```

* Windows:

  Run PowerShell and enter command, for example:

  ```
  PS C:\> ./transferInstanceConfig.ps1 -sourceInstance "http://source_machine:8080/njams" -targetInstance "http://target_machine:8080/njams" -dataProvider
  ```

* macOS:

  Run a shell and enter command, for example:

  ```
  $ pwsh -c './transferInstanceConfig.ps1 -sourceInstance "http://source_machine:8080/njams" -targetInstance "http://target_machine:8080/njams" -dataProvider'
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