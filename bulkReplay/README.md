# bulkReplay
Script for replaying process executions by configuration using Replay Command line tool.

## Description:

Replay Command line tool allows to query for process executions in a given nJAMS instance and to replay these exections. This script provides a configuration file to query and replay process executions in a more convenient way.


## How it works:

This script reads the content of the configuration file "replay.properties", queries for process executions in the specified nJAMS instance according to the given search criteria, and replays the found entries in the same nJAMS instance.


## Usage:

1. Copy the content of this repository to a folder of your machine
2. Make sure Java 11 is installed on this machine
3. Edit "replay.properties" file according to your needs
4. Execute this script


## Characteristics:

* reorganizes nJAMS H2 database by rebuilding H2 database file
* supports H2 database files of nJAMS Server 5.x


## Requirements:

  - Java 11 or higher is required
  - Make sure there is enough disk space available on the machine, where you execute the script. 
  - You need read/write permission on working directory
