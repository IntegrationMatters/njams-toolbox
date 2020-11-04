# h2-maintenance
Rebuilds H2 database of nJAMS Server instance.

## Description:

The internal "H2" database of nJAMS Server is a lightweight, efficient and low maintenance relational database management system (RDBMS).

However, from time to time it may be required to compact H2 database file. Especially when nJAMS Server is running continously over weeks or months, the H2 database file may increase significantly. The H2 database is automatically compacted, when closing the database. In order to close and compact H2 database, nJAMS Server must be stopped and restarted. It is recommended to restart nJAMS Server periodically to perform compacting the H2 database.

This maintenance script goes beyond and rebuilds the H2 database. Whereas compacting a database just releases unused space of the database, the data structures are kept untouched. In contrast, rebuilding the database will re-create the indexes and lead to even smaller database size and overall better performance of the database.

We provide h2-maintenance scripts for Windows, Linux, or Mac.

## How it works:

First the script exports the nJAMS H2 database file `njams.mv.db` into a temporary ZIP file. Secondly a new H2 database file is created based on the export. For more details see the description of the individual script in bash, cmd, or ps1.


## Characteristics:

* shrinks nJAMS H2 database by rebuilding H2 database file
* supports H2 database files of nJAMS Server 5.x


## Requirements:

  - Java 8 or higher is required
  - Make sure there is enough disk space available on the machine, where you execute the script. 
  - You need read/write permission on working directory
  - If applicable, you need read/write permission on nJAMS installation directory
