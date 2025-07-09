# 🔐 Enabling HTTPS (SSL/TLS) for nJAMS

This guide explains how to enable HTTPS for nJAMS (new setup or upgrade).

---

## ✅ 1. Enable HTTPS on a new nJAMS installation

1. **Place your JKS keystore** (e.g. `wildcard.integrationmatters.com.jks`) in a location accessible by WildFly.  
   🔹 **Recommended path:** `/home/<user>/njams/data/`

2. **Copy the following scripts** to your WildFly's `bin` folder (e.g. `wildfly27/bin/`):  
   - `enable-https.sh`  
   - `ssl-config-template.cli`

3. **Edit the `enable-https.sh` script**:  
   - Make sure all paths and file names are correct (keystore path, WildFly version, etc.)

4. **Run the script**:  

   sh enable-https.sh
   

---

## 🔁 2. Upgrade from an existing SSL-enabled nJAMS instance

If your current nJAMS version already uses HTTPS, the installer **must be able to connect via HTTP** during the upgrade.

### Temporarily enable HTTP:

1. **Copy the following scripts** into your existing WildFly’s `bin` folder (e.g. `wildfly27/bin/`):  
   - `temporarily-enable-http.sh`  
   - `enable-temp-http.cli`

2. **Edit the `temporarily-enable-http.sh` script**:  
   - Ensure all file paths are correct.

3. **Run the script**:  

   sh temporarily-enable-http.sh
   

4. Proceed with the upgrade.

---

## 🔄 3. After upgrade: Re-enable HTTPS

The upgrade installs a **new WildFly version** (e.g. `wildfly32`).

1. **Copy the HTTPS scripts** again to the new WildFly folder:  
   - `enable-https.sh`  
   - `ssl-config-template.cli`  
   → Place both in: `wildfly32/bin/`

2. **Edit the `enable-https.sh` script** and update all paths if needed.

3. **Run the script** to re-enable HTTPS:  
   
   sh enable-https.sh
   

---

✅ That’s it.  
Your updated nJAMS version now runs securely via HTTPS again.

If you have questions, contact Integration Matters Support.