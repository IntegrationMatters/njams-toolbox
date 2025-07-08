Temporary HTTP Access for WildFly – How to Use

There are situations where you may need to temporarily reopen HTTP access to your WildFly server.
For example, the nJAMS installer requires access to WildFly via HTTP to perform an update of an existing nJAMS instance.
In such cases, HTTP access to WildFly must be temporarily re-enabled for the duration of the update.

How to Temporarily Re-Enable HTTP Access

1. Prepare the Scripts

   You have the following two files:
   - enable-temp-http.cli: CLI commands to enable HTTP
   - temporarily-enable-http.sh: Shell script to execute the CLI

2. Adjust the Shell Script

   Open temporarily-enable-http.sh and set the required paths:

   JBOSS_CLI_PATH="/path/to/your/jboss-cli.sh"
   CLI_SCRIPT_PATH="/path/to/enable-temp-http.cli"
   CONTROLLER="127.0.0.1:9990"  # Adjust if needed

3. Run the Script

   Make the script executable:

   chmod +x temporarily-enable-http.sh

   Then execute:

   ./temporarily-enable-http.sh

4. Perform the Required Update

   Run your nJAMS installer or other processes that require HTTP access to WildFly.

Important:

Remember to disable HTTP again after completing your update for security reasons.

