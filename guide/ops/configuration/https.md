---
title: HTTPS Configuration
layout: website-normal
---

## Getting the Certificate
To enable HTTPS web access, you will need a server certificate in a java keystore. To create a self-signed certificate,
for testing and non-production use, you can use the tool `keytool` from your Java distribution. (A self-signed 
certificate will cause a warning to be displayed by a browser when viewing the page. The various browsers each have 
ways to import the certificate as a trusted one, for test purposes.)

The following command creates a self-signed certificate and adds it to a keystore, `keystore.jks`:

```bash
% keytool -genkey -keyalg RSA -alias brooklyn \
          -keystore <path-to-keystore-directory>/keystore.jks -storepass "mypassword" \
          -validity 365 -keysize 2048 -keypass "password"
```

The passwords above should be changed to your own values.  Omit those arguments above for the tool to prompt you for the values.

You will then be prompted to enter your name and organization details. This will use (or create, if it does not exist)
a keystore with the password `mypassword` - you should use your own secure password, which will be the same password
used in your `brooklyn.cfg` (below). You will also need to replace `<path-to-keystore-directory>` with the full 
path of the folder where you wish to store your keystore. The keystore will contain the newly generated key, 
with alias `brooklyn` and password `password`.

For production servers, a valid signed certificate from a trusted certifying authority should be used instead.
Typically keys from a certifying authority are not provided in Java keystore format.  To create a Java keystore from 
existing certificates (CA certificate, and public and private keys), you must first create a PKCS12 keystore from them,
for example with `openssl`; this can then be converted into a Java keystore with `keytool`. For example, with 
a CA certificate `ca.pem`, and public and private keys `cert.pem` and `key.pem`, create the PKCS12 store `server.p12`,
and then convert it into a keystore `keystore.jks` as follows:
 
```bash
% openssl pkcs12 -export -in cert.pem -inkey key.pem \
               -out server.p12 -name "brooklyn" \
               -CAfile ca.pem -caname root -chain -passout pass:"password"

% keytool -importkeystore \
        -deststorepass "password" -destkeypass "password" -destkeystore keystore.jks \
        -srckeystore server.p12 -srcstoretype PKCS12 -srcstorepass "password" \
        -alias "brooklyn"
```


## HTTPS Configuration

In [`org.ops4j.pax.web.cfg`](../paths.html) in the Brooklyn distribution root, un-comment the settings:

```properties
org.osgi.service.http.port.secure=8443
org.osgi.service.http.secure.enabled=true
org.ops4j.pax.web.ssl.keystore=${karaf.home}/etc/keystores/keystore.jks
org.ops4j.pax.web.ssl.password=password
org.ops4j.pax.web.ssl.keypassword=password
org.ops4j.pax.web.ssl.clientauthwanted=false
org.ops4j.pax.web.ssl.clientauthneeded=false
```

replacing the passwords with appropriate values, and restart the server. Note the keystore location is relative to 
the installation root, but a fully qualified path can also be given, if it is desired to use some separate pre-existing
store.
