---
title: HTTPS Configuration
layout: website-normal
---

## HTTPS Configuration

### Getting the Certificate
To enable HTTPS web access, you will need a server certificate in a java keystore. To create a self-signed certificate,
and add it to a keystore, `keystore.jks`, you can use the following command:

{% highlight bash %}
% keytool -genkey -keyalg RSA -alias brooklyn \
          -keystore <path-to-keystore-directory>/keystore.jks -storepass "mypassword" \
          -validity 365 -keysize 2048 -keypass "password"
{% endhighlight %}

Of course, the passwords above should be changed.  Omit those arguments above for the tool to prompt you for the values.

You will then be prompted to enter your name and organization details. This will use (or create, if it does not exist)
a keystore with the password `mypassword` - you should use your own secure password, which will be the same password
used in your brooklyn.properties (below). You will also need to replace `<path-to-keystore-directory>` with the full 
path of the folder where you wish to store your keystore. The keystore will contain the newly generated key, 
with alias `brooklyn` and password `password`.

The certificate generated will be a self-signed certificate, which will cause a warning to be displayed by a browser 
when viewing the page. (The various browsers each have ways to import the certificate as a trusted one, for test purposes.)

For production servers, a valid signed certificate from a trusted certifying authority should be used instead.
Typically keys from a certifying authority are not provided in Java keystore format.  To create a Java keystore from 
existing certificates (CA certificate, and public and private keys), you must first create a PKCS12 keystore from them,
for example with `openssl`; this can then be converted into a Java keystore with `keytool`. For example, with 
a CA certificate `ca.pem`, and public and private keys `cert.pem` and `key.pem`, create the PKCS12 store `server.p12`,
and then convert it into a keystore `keystore.jks` as follows:
 
{% highlight bash %}
% openssl pkcs12 -export -in cert.pem -inkey key.pem \
               -out server.p12 -name "brooklyn" \
               -CAfile ca.pem -caname root -chain -passout pass:"password"

% keytool -importkeystore \
        -deststorepass "password" -destkeypass "password" -destkeystore keystore.jks \
        -srckeystore server.p12 -srcstoretype PKCS12 -srcstorepass "password" \
        -alias "brooklyn"
{% endhighlight %}


### Configuring Brooklyn for HTTPS

How to do this depends on whether you are using the traditional or the Karaf distribution. See either of

* [Traditional Distribution](brooklyn_properties.html#https-configuration)
* [Karaf Distribution](osgi-configuration.html#https-configuration)
