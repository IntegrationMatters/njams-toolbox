#!/bin/bash

# === Adjustable Paths ===

# Path to your jboss-cli.sh
JBOSS_CLI_PATH="{YOUR PATH TO JBOSS-CLI.SH}"
# example: JBOSS_CLI_PATH="/home/tibco/njams/wildfly27/bin/jboss-cli.sh"

# Path to your CLI script
CLI_SCRIPT_PATH="{YOUR PATH TO THE CLI SCRIPT}"
# example: CLI_SCRIPT_PATH="/home/tibco/njams/wildfly27/bin/enable-temp-http.cli"

# Management Controller (can be adjusted if needed)
CONTROLLER="{MANAGEMENT CONTROLLER}"
# example: CONTROLLER="127.0.0.1:9990"

# === Execution ===

"$JBOSS_CLI_PATH" --connect --controller="$CONTROLLER" --file="$CLI_SCRIPT_PATH"
