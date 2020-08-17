# setLogLevel.sh
Set log level for domain objects with regards to a given domain object path of an nJAMS instance.

## Description:

This script changes the log level of domain objects related to a specified domain object path. The log level can be set to INFO, SUCCESS, WARNING, or ERROR.

It is required to modify the following variables in the script according to your requirements:

* njamsInstanceUrl - the url of your nJAMS Server instance

* njamsUser - nJAMS username

* njamsPW - password of nJAMS user

* domainObjectPath - the path of domain objects you want to change the log level

* domainObjectLogLevel - new log level

The script runs on Linux/Unix using bash.

## Example:

njamsInstanceUrl="http://10.189.0.137:8080/njams"
njamsUser="admin"
njamsPW="admin"
domainObjectPath="%3Eprod%3Efinance%3Einvoicing%3E"
domainObjectLogLevel="ERROR" # INFO | SUCCESS | WARNING | ERROR

## Execution:

Run a shell and enter command:

```
$ setLogLevel.sh
```

## Prerequisites:

  This script requires *jq 1.5*. JQ is a lightweight and flexible command-line JSON processor. See https://stedolan.github.io/jq/ for more information about *jq*.

  Installation: 
  
  ```
  sudo apt-get install jq
  ```
