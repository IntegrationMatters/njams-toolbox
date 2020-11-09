# h2-maintenance.sh
Rebuilds H2 database of an nJAMS Server instance.

## Description:

This maintenance script rebuilds the nJAMS H2 database. Unused space will be released and the indexes are re-created. The script can be executed on a Linux/Unix machine.

## How it works:

First the script exports the nJAMS H2 database file `njams.mv.db` into a temporary ZIP file. Secondly a new H2 database file is created based on the export.

  1. Copy the script to a working folder of a Linux/Unix machine that has sufficient free disk space and has installed Java 8 or higher.
  2. Shutdown nJAMS Server.
  3. Copy `njams.mv.db` from `<njams-installation>/data/h2/` of your nJAMS Server machine to the working folder of this machine.
  4. Copy H2 JDBC driver jar file from `<njams-installation>/wildfly16/modules/system/layers/base/com/h2database/h2/main/` of your nJAMS Server machine to the working folder.
  5. Open a terminal and CD to the working folder.
  6. Run the script. If applicable, enter the credentials to access nJAMS H2 database by specifying username and password. The new nJAMS H2 database is created in subfolder `target` of your working folder. You will notice, the new file is significantly smaller than the original file.
  7. Replace the original nJAMS H2 database file on nJAMS Server machine with the newly created H2 database file.
  8. Restart nJAMS Server.

## Characteristics:

* reorganizes nJAMS H2 database by rebuilding H2 database file
* supports H2 database files of nJAMS Server 5.x
* runs on Linux/Unix using bash

## Usage:

```
SYNTAX
    ./h2-maintenance.sh db-user password [db-name]
```

Run `./h2-maintenance.sh -?` to learn more about how to use the script. 

## Execution:

* Linux/Unix:

  Open a Terminal and enter command, for example:

  ```
  $ ./h2-maintenance.sh admin admin
  ```

## Prerequisites:

* General requirements:

  - Java 8 or higher is required
  - Make sure there is enough disk space available on the machine, where you execute the script. 
  - You need read/write permission on working directory
