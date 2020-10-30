# nJAMS toolbox
This repository contains tools that can help you with the daily use of nJAMS. Let us know if you have any issues using them, there is always space for improvement. Feel free to fork.

* **findDomainObjects**

  Find domain objects of given nJAMS instance. Assume you have a big nJAMS instance containing hundreds of domain objects and you want to find the domain objects that match a specific configuration. For example, you may want to find domain objects with an incorrect 'retention' setting, or domain objects that have accidentally turned on 'StripOnSuccess'. This script will easily find these domain objects.

* **h2-maintenance**

  The internal "H2" database of nJAMS Server is a lightweight, efficient and low maintenance relational database management system (RDBMS).
  However, from time to time it may be required to compact H2 database file. Especially when nJAMS Server is running continously over weeks or months, the H2 database file may increase significantly. The H2 database is automatically compacted, when closing the database. In order to close and compact H2 database, nJAMS Server must be stopped and restarted.

  This maintenance script goes beyond and rebuilds the H2 database. Rebuilding the database will further reduce the database size, since it will also rebuild the indexes.

* **setLogLevel**

  Set log level for domain objects with regards to a given domain object path of an nJAMS instance. Assume you want to change the log level for several domain objects and you do not want to change each domain object one by one in nJAMS UI. This script will help you to change the log level for domain objects of a specific path and its sub elements.

* **transferInstanceConfig**

  Transfer the configuration settings from a given source nJAMS instance to a given target nJAMS instance. This tool might be useful, if you want to create a new nJAMS instance based on the same settings of an existing nJAMS instance.
