Enable HTTPS for WildFly

This script enables HTTPS and configures HTTP-to-HTTPS redirection for your WildFly server.
The switch to HTTPS is applied automatically by running the provided enable-https.sh script — adjust the script before executing.

Prerequisites
- A valid .jks keystore containing your SSL certificate and private key.
- The keystore password.
- Correct file paths and port configuration.

Steps to Apply HTTPS

1. Prepare your .jks file
   Place your keystore .jks anywhere on the system, for example:
   /home/ubuntu/njams/data/certificates/your-certificate.jks


2. Edit enable-https.sh
   At the top of the script, set your values:

   export JKS_PATH="/path/to/your/file.jks"
   export JKS_PASSWORD="your-keystore-password"
   export PUBLIC_IP="your-public-ip"
   export HTTP_PORT="8080"
   export HTTPS_PORT="8443"

   Adjust the following lines to reference your CLI template and WildFly CLI:

   envsubst < /path/to/ssl-config-template.cli > /tmp/ssl-config.cli
   /path/to/jboss-cli.sh --connect --file=/tmp/ssl-config.cli

3. Execute the Script

   chmod +x enable-https.sh
   ./enable-https.sh

Additional Notes
- After applying HTTPS, a WildFly reload may be required:

  /path/to/jboss-cli.sh --connect --command="reload"

- Make sure ports for HTTP and HTTPS are open on the firewall.

Security Recommendation

Store your .jks file securely.
Avoid hardcoding passwords in production scripts; use environment variables or secured configurations.
