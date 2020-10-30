# h2-maintenance.cmd
Rebuilds H2 database of an nJAMS Server instance.

## Description:

The internal "H2" database of nJAMS Server is a lightweight, efficient and low maintenance relational database management system (RDBMS).

However, from time to time it may be required to compact H2 database file. Especially when nJAMS Server is running continously over weeks or months, the H2 database file may increase significantly. The H2 database is automatically compacted, when closing the database. In order to close and compact H2 database, nJAMS Server must be stopped and restarted.

This maintenance script goes beyond and rebuilds the H2 database. Rebuilding the database will further reduce the database size, since it will also rebuild the indexes.

This script can be executed on any Windows machine.

## How it works:

First the script exports the nJAMS H2 database file ("njams.mv.db") into a temporary ZIP file. Secondly a new H2 database file is created based on the export.

  1. Copy the script to a working folder of a Windows machine that has sufficient free disk space and has installed Java 8 or higher.
  2. Shutdown nJAMS Server.
  3. Copy `njams.mv.db` from `<njams-installation>/data/h2/` of your nJAMS Server machine to the working folder of this machine.
  4. Copy H2 JDBC driver jar file from `<njams-installation>/wildfly16/modules/system/layers/base/com/h2database/h2/main/` of your nJAMS Server machine to the working folder.
  5. Open Windows Command Prompt and CD to the working folder.
  6. Run the script. If applicable, enter the credentials to access nJAMS H2 database by specifying username and password.

  -> The new nJAMS H2 database is created in subfolder `target` of your working folder. You will notice, the new file is significantly smaller than the original file.
  
  8. Replace the original nJAMS H2 database file on nJAMS Server machine with the newly created H2 database file.

## Characteristics:

* shrinks nJAMS H2 database by rebuilding H2 database file
* supports H2 database files of nJAMS Server 5.x
* runs on Windows using Windows Command Prompt

## Usage:

```
SYNTAX
    h2-maintenance.cmd db-user password [db-name]
```

Run `h2-maintenance.cmd -?` to learn more about how to use the script. 

## Execution:

* Windows:

  Run Windows Command Prompt and enter command, for example:

  ```
  C:\temp\working> h2-maintenance.cmd admin admin
  ```

## Prerequisites:

* General requirements:

  - Java 8 or higher is required
  - Make sure there is enough disk space available on the machine, where you execute the script. 
  - You need read/write permission on working directory
