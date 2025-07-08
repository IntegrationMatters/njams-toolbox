# ------------------------------------------------------------------
# ENABLE HTTPS FOR WILDFLY (nJAMS)
#
# 1. Place your .jks file (with private key and cert) somewhere accessible
#    → Recommended: /home/<user>/njams/data/...
#
# 2. Fill in the variables below (paths, passwords, ports).
# 3. Make sure the CLI template (.cli) and this script are in wildflyXY/bin/
# 4. Adjust paths in the script (JKS, CLI file, jboss-cli.sh)
# 5. Run this script: chmod +x enable-https.sh && ./enable-https.sh
#
# After upgrade: re-run this script for the new WildFly version
# ------------------------------------------------------------------

#!/bin/bash

# === Define your values here ===

export JKS_PATH="{YOUR PATH TO .JKS}"
# example: export JKS_PATH="/home/tibco/njams/data/cert.wildcard.integrationmatters.com/wildcard.integrationmatters.com.jks"
export JKS_PASSWORD="{PASSWORD FOR JKS}"
# example: export JKS_PASSWORD="njams"
export PUBLIC_IP="{YOUR IP ADRESS}"
# example: export PUBLIC_IP="10.30.0.177"
export HTTP_PORT="{HTTP PORT}"
# example: export HTTP_PORT="8080"
export HTTPS_PORT="{HTTPS PORT}"
# example: export HTTPS_PORT="8443"

# === Inject values into the CLI template ===
envsubst < {YOUR PATH TO .CLI SCRIPT} > /tmp/ssl-config.cli
# example: envsubst < /home/tibco/njams/wildfly27/bin/ssl-config-template.cli > /tmp/ssl-config.cli

# === Show the final CLI file (optional, for debug) ===
#echo "==== Final CLI ===="
#cat /tmp/ssl-config.cli
#echo "==================="

# === Run the CLI ===
{YOUR PATH TO JBOSS-CLI.SH} --connect --file=/tmp/ssl-config.cli

# example: /home/tibco/njams/wildfly27/bin/jboss-cli.sh --connect --file=/tmp/ssl-config.cli