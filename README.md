# nJAMS toolbox
This repository contains tools that can help you with the daily use of nJAMS. Let us know if you have any issues using them or you have some other good ideas, there is always space for improvement.

* **findDomainObjects**

  Find domain objects of given nJAMS instance. Assume you have a big nJAMS instance containing hundreds of domain objects and you want to find the domain objects that match a specific configuration. For example, you may want to find domain objects with an incorrect 'retention' setting, or domain objects that have accidentally turned on 'StripOnSuccess'. This script will easily find these domain objects.

* **h2-maintenance**

  The internal "H2" database of nJAMS Server is a lightweight, efficient and low maintenance relational database management system (RDBMS).
  However, from time to time it may be required to compact H2 database file. Especially when nJAMS Server is running continously over weeks or months, the H2 database file may increase significantly. The H2 database is automatically compacted, when closing the database. In order to close and compact H2 database, nJAMS Server must be stopped and restarted.

  This maintenance script goes beyond and rebuilds the H2 database. Rebuilding the database will lead to even smaller database size and overall better performance of the database.

* **setLogLevel**

  Set log level for domain objects with regards to a given domain object path of an nJAMS instance. Assume you want to change the log level for several domain objects and you do not want to change each domain object one by one in nJAMS UI. This script will help you to change the log level for domain objects of a specific path and its sub elements.

* **transferInstanceConfig**

  Transfer the configuration settings from a given source nJAMS instance to a given target nJAMS instance. This tool might be useful, if you want to create a new nJAMS instance based on the same settings of an existing nJAMS instance.

* **setDbDialect**

  Set DB dialect in WildFly configuration in order to use Oracle 19 or higher with nJAMS Server.

* **bulkReplay**

  Query and replay process executions of a given nJAMS instance using nJAMS Replay Command line tool based on a configuration file.

* **getPayload**

  Outputs payload data into files from activities of process executions of a given process and a period of time.
