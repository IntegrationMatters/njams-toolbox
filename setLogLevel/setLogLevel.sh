#!/bin/sh
#
# This script sets LogLevel to all sub elements of a domain object path
# Dependencies: jq 1.5: a lightweight and flexible command-line JSON processor. https://stedolan.github.io/jq/
# installation: sudo apt-get install jq
# (c) Integration Matters 2020

# -------------------------------------------------------
# Declare global variables:
# nJAMS instance:
njamsInstanceUrl="http://10.189.0.137:8080/njams"
njamsUser="admin"
njamsPW="admin"
domainObjectPath="%3Edomain%3Edeployment%3Esupport%3E"
domainObjectLogLevel="ERROR" # INFO | SUCCESS | WARNING | ERROR

# (1) Login as admin:
echo "Login..."
curl -c cookiefile -X POST --header 'Content-Type: application/json' --header 'Accept: text/plain' -d '{  
	"username": "'$njamsUser'",  
	"password": "'$njamsPW'"  
}' ''$njamsInstanceUrl'/api/usermanagement/authentication'  > /dev/null
 
# (2) Get list of sub elements of given domain object path:
echo "List of sub elements..."
objectIds=`curl -b cookiefile -X GET --header 'Accept: application/json' ''$njamsInstanceUrl'/api/domainobject/path/'$domainObjectPath'' | jq '.[].id'`

# Display the total number of sub elements
linenum=`echo $objectIds | wc -w`
echo $linenum "sub elements to set LogLevel for."

# (3) Loop each sub element and set LogLevel
i=0
for line in $objectIds; do
    i=$((i+1))
    echo $i/$linenum - "Set LogLevel='$domainObjectLogLevel' for domain object Id: "$line
	curl -b cookiefile -X PUT --header 'Content-Type: application/json' --header 'Accept: application/json' -d '{ "logLevel": "'$domainObjectLogLevel'" }' ''$njamsInstanceUrl'/api/domainobject/'$line''
	echo ""
    sleep 1
done

