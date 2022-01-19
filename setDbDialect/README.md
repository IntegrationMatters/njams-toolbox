# setDialect.cli
Set DB dialect in WildFly configuration in order to use Oracle 19 or higher with nJAMS Server.

## Description:

When you plan to migrate your Oracle Database to version 19 or higher, you should also consider to update the database connection of nJAMS Server in terms of configuring db dialect and/or updating Oracle JDBC driver.

The database connection of nJAMS Server is part of the WildFly configuration. This CLI script updates WildFly system property "njams.db.dialect" to "org.hibernate.dialect.Oracle12cDialect".

## How to use:

(1) Copy "setDialect.cli" to "<your-njams-installation>/wildfly16/"

(2) While WildFly is running, execute the script: $JBOSS_HOME/bin/jboss-cli.sh -c --file=setDialect.cli

(3) Restart WildFly. You can use the start/stop scripts in folder <your-njams-installation>/bin

## Requirements:

  - nJAMS Server 5.0, 5.1
  - Make sure WildFly is running
  - You need read/write permission on WildFly directory


# createNewDriverAndSetDialect.cli
Set DB dialect in WildFly configuration and add new JDBC driver at the same time.

## Description:

In case you also want to update the Oracle JDBC driver at the same time, you can use CLI script "createNewDriverAndSetDialect.cli". This script will set db dialect and additionally creates a new entry in WildFly at Configuration > Subsystems > Datasources & Drivers > JDBC Drivers.

## How to use:

(1) Copy "createNewDriverAndSetDialect.cli" to <your-njams-installation>/wildfly16/

(2) Copy the new ojdbc.jar file to a location of your choice on your nJAMS Server machine, e.g. your home directory "~/"

(3) Edit script "createNewDriverAndSetDialect.cli" and specify the full path to your ojdbc.jar file at "module add --resources", e.g. module add --name=com.oracle19 --resources="~/ojdbc8.jar" --dependencies=javax.api,javax.transaction.api

(4) While WildFly is running, execute the script: $JBOSS_HOME/bin/jboss-cli.sh -c --file=createNewDriverAndSetDialect.cli

(5) Restart WildFly. You can use the start/stop scripts in folder <your-njams-installation>/bin

## Requirements:

  - nJAMS Server 5.0, 5.1
  - Make sure WildFly is running
  - You need read/write permission on WildFly directory


# createNewMssqlJdbcDriver.cli
Add new Microsoft SQL JDBC driver in WildFly configuration.

## Description:

In case you want to update the MS SQL JDBC driver, you can use CLI script "createNewMssqlJdbcDriver.cli". This script is predesigned for adding a new MS SQL JDBC driver and will create a new entry in WildFly at Configuration > Subsystems > Datasources & Drivers > JDBC Drivers. You just have to specifiy the location of JDBC driver filename in the script.

## How to use:

(1) Copy "createNewMssqlJdbcDriver.cli" to <your-njams-installation>/wildfly16/

(2) Copy the new mssql-jdbc-9.x.x.jre11.jar file to a location of your choice on your nJAMS Server machine, e.g. your home directory "~/"

(3) Edit script "createNewMssqlJdbcDriver.cli" and specify the full path to your mssql-jdbc-9.x.x.jre11.jar file at "module add --resources", e.g. module add --name=njams.com.mssql2019 --resources="~/mssql-jdbc-9.4.1.jre11.jar" --dependencies=javax.api,javax.transaction.api

(4) While WildFly is running, execute the script: $JBOSS_HOME/bin/jboss-cli.sh -c --file=createNewMssqlJdbcDriver.cli

(5) Restart WildFly. You can use the start/stop scripts in folder <your-njams-installation>/bin

## Requirements:

  - nJAMS Server 5.0, 5.1
  - Make sure WildFly is running
  - You need read/write permission on WildFly directory

