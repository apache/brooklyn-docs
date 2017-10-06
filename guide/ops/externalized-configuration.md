---
title: Externalized Configuration
layout: website-normal
---

Sometimes it is useful that configuration in a blueprint, or in Brooklyn itself, is not given explicitly, but is instead
replaced with a reference to some other storage system. For example, it is undesirable for a blueprint to contain a
plain-text password for a production system, especially if (as we often recommend) the blueprints are kept in the
developer's source code control system.

To handle this problem, Apache Brooklyn supports externalized configuration. This allows a blueprint to refer to
a piece of information that is stored elsewhere. `brooklyn.cfg` defines the external suppliers of configuration
information. At runtime, when Brooklyn finds a reference to externalized configuration in a blueprint, it consults
`brooklyn.cfg` for information about the supplier, and then requests that the supplier return the information
required by the blueprint.

Take, as a simple example, a web app which connects to a database. In development, the developer is running a local
instance of PostgreSQL with a simple username and password. But in production, an enterprise-grade cluster of PostgreSQL
is used, and a dedicated service is used to provide passwords. The same blueprint can be used to service both groups
of users, with `brooklyn.cfg` changing the behaviour depending on the deployment environment.

Here is the blueprint:

```yaml
name: MyApplication
services:
- type: brooklyn.entity.webapp.jboss.JBoss7Server
  name: AppServer HelloWorld
  brooklyn.config:
    wars.root: http://search.maven.org/remotecontent?filepath=org/apache/brooklyn/example/brooklyn-example-hello-world-sql-webapp/0.8.0-incubating/brooklyn-example-hello-world-sql-webapp-0.8.0-incubating.war
    http.port: 8080+
    java.sysprops:
      brooklyn.example.db.url: 
        $brooklyn:formatString:
          - jdbc:postgresql://%s/myappdb?user=%s\\&password=%s
          - $brooklyn:external("servers", "postgresql")
          - $brooklyn:external("credentials", "postgresql-user")
          - $brooklyn:external("credentials", "postgresql-password")
```

You can see that when we are building up the JDBC URL, we are using the `external` function. This takes two parameters:
the first is the name of the configuration supplier, the second is the name of a key that is stored by the configuration
supplier. In this case we are using two different suppliers: `servers` to store the location of the server, and
`credentials` which is a security-optimized supplier of secrets.

Developers would add lines like this to the `brooklyn.cfg` file on their workstation:

```properties
brooklyn.external.servers=org.apache.brooklyn.core.config.external.InPlaceExternalConfigSupplier
brooklyn.external.servers.postgresql=127.0.0.1
brooklyn.external.credentials=org.apache.brooklyn.core.config.external.InPlaceExternalConfigSupplier
brooklyn.external.credentials.postgresql-user=admin
brooklyn.external.credentials.postgresql-password=admin
```

In this case, all of the required information is included in-line in the local `brooklyn.cfg`.

Whereas in production, `brooklyn.cfg` might look like this:

```properties
brooklyn.external.servers=org.apache.brooklyn.core.config.external.PropertiesFileExternalConfigSupplier
brooklyn.external.servers.propertiesUrl=https://ops.example.com/servers.properties
brooklyn.external.credentials=org.apache.brooklyn.core.config.external.vault.VaultAppIdExternalConfigSupplier
brooklyn.external.credentials.endpoint=https://vault.example.com
brooklyn.external.credentials.path=secret/enterprise-postgres
brooklyn.external.credentials.appId=MyApp
```

In this case, the list of servers is stored in a properties file located on an Operations Department web server, and the
credentials are stored in an instance of [Vault](https://www.vaultproject.io/).
More information on these providers is below.

For demo purposes, there is a pre-defined external provider called
`brooklyn-demo-sample` which defines `hidden-brooklyn-password` as `br00k11n`.
This is used in some of the sample blueprints, referencing `$brooklyn:external("brooklyn-demo-sample", "hidden-brooklyn-password")`. 
The value used here can be overridden with the following in your `brooklyn.cfg`:

```properties
brooklyn.external.brooklyn-demo-sample=org.apache.brooklyn.core.config.external.InPlaceExternalConfigSupplier
brooklyn.external.brooklyn-demo-sample.hidden-brooklyn-password=new_password
```


## Defining Suppliers

External configuration suppliers are defined in `brooklyn.cfg`. The minimal definition is of the form:

brooklyn.external.*supplierName* = *className*

This defines a supplier named *supplierName*. Brooklyn will attempt to instantiate *className*; it is this class which
will provide the behaviour of how to retrieve data from the supplier. Brooklyn includes a number of supplier
implementations; see below for more details.

Suppliers may require additional configuration options. These are given as additional properties in
`brooklyn.cfg`:

```properties
brooklyn.external.supplierName = className
brooklyn.external.supplierName.firstConfig = value
brooklyn.external.supplierName.secondConfig = value
```

## Referring to External Configuration in Blueprints

Externalized configuration adds a new function to the Brooklyn blueprint language DSL, `$brooklyn:external`. This
function takes two parameters:

1. supplier
2. key

When resolving the external reference, Brooklyn will first identify the *supplier* of the information, then it will
give the supplier the *key*. The returned value will be substituted into the blueprint.

You can use `$brooklyn:external` directly:

```yaml
name: MyApplication
brooklyn.config:
  example: $brooklyn:external("supplier", "key")
```

or embed the `external` function inside another `$brooklyn` DSL function, such as `$brooklyn:formatString`:

```yaml
name: MyApplication
brooklyn.config:
  example: $brooklyn:formatString("%s", external("supplier", "key"))
```


## Referring to External Configuration in brooklyn.cfg

The same blueprint language DSL can be used from `brooklyn.cfg`. For example:

```properties
brooklyn.location.jclouds.aws-ec2.identity=$brooklyn:external("mysupplier", "aws-identity")
brooklyn.location.jclouds.aws-ec2.credential=$brooklyn:external("mysupplier", "aws-credential")
```


## Referring to External Configuration in Catalog Items

The same blueprint language DSL can be used within YAML catalog items. For example:

    brooklyn.catalog:
      id: com.example.myblueprint
      version: "1.2.3"
      itemType: entity
      brooklyn.libraries:
      - >
        $brooklyn:formatString("https://%s:%s@repo.example.com/libs/myblueprint-1.2.3.jar", 
        external("mysupplier", "username"), external("mysupplier", "password"))
      item:
        type: com.example.MyBlueprint

Note the `>` in the example above is used to split across multiple lines.


## Suppliers available with Brooklyn

Brooklyn ships with a number of external configuration suppliers ready to use.

### In-place

**InPlaceExternalConfigSupplier** embeds the configuration keys and values as properties inside `brooklyn.cfg`.
For example:

```properties
brooklyn.external.servers=org.apache.brooklyn.core.config.external.InPlaceExternalConfigSupplier
brooklyn.external.servers.postgresql=127.0.0.1
```

Then, a blueprint which referred to `$brooklyn:external("servers", "postgresql")` would receive the value `127.0.0.1`.

### Properties file

**PropertiesFileExternalConfigSupplier** loads a properties file from a URL, and uses the keys and values in this
file to respond to configuration lookups.

Given this configuration:

```properties
brooklyn.external.servers=org.apache.brooklyn.core.config.external.PropertiesFileExternalConfigSupplier
brooklyn.external.servers.propertiesUrl=https://ops.example.com/servers.properties
```

This would cause the supplier to download the given URL. Assuming that the file contained this entry:

```properties
postgresql=127.0.0.1
```

Then, a blueprint which referred to `$brooklyn:external("servers", "postgresql")` would receive the value `127.0.0.1`.

### Vault

[Vault](https://www.vaultproject.io) is a server-based tool for managing secrets. Brooklyn provides suppliers that are
able to query the Vault REST API for configuration values. The different suppliers implement alternative authentication
options that Vault provides.

For *all* of the authentication methods, you must always set these properties in `brooklyn.cfg`:

```properties
brooklyn.external.supplierName.endpoint=<Vault HTTP/HTTPs endpoint>
brooklyn.external.supplierName.path=<path to a Vault object>
```

For example, if the path is set to `secret/brooklyn`, then attempting to retrieve the key `foo` would cause Brooklyn
to retrieve the value of the `foo` key on the `secret/brooklyn` object. This value can be set using the Vault CLI
like this:

```bash
vault write secret/brooklyn foo=bar
```

#### Authentication by username and password

The `userpass` plugin for Vault allows authentication with username and password.

```properties
brooklyn.external.supplierName=org.apache.brooklyn.core.config.external.vault.VaultUserPassExternalConfigSupplier
brooklyn.external.supplierName.username=fred
brooklyn.external.supplierName.password=s3kr1t
```

#### Authentication using App ID

The `app_id` plugin for Vault allows you to specify an "app ID", and then designate particular "user IDs" to be part
of the app. Typically the app ID would be known and shared, but user ID would be autogenerated on the client in some
way. Brooklyn implements this by determining the MAC address of the server running Brooklyn (expressed as 12 lower
case hexadecimal digits without separators) and passing this as the user ID.

```properties
brooklyn.external.supplierName=org.apache.brooklyn.core.config.external.vault.VaultAppIdExternalConfigSupplier
brooklyn.external.supplierName.appId=MyApp
```

If you do not wish to use the MAC address as the user ID, you can override it with your own choice of user ID:

```properties
brooklyn.external.supplierName.userId=server3.cluster2.europe
```

#### Authentication by fixed token

If you have a fixed token string, then you can use the *VaultTokenExternalConfigSupplier* class and provide the token
in `brooklyn.cfg`:

```properties
brooklyn.external.supplierName=org.apache.brooklyn.core.config.external.vault.VaultTokenExternalConfigSupplier
brooklyn.external.supplierName.token=1091fc84-70c1-b266-b99f-781684dd0d2b
```

This supplier is suitable for "smoke testing" the Vault supplier using the Initial Root Token or similar. However it
is not suitable for production use as it is inherently insecure - should the token be compromised, an attacker could
have complete access to your Vault, and the cleanup operation would be difficult. Instead you should use one of the
other suppliers.

## Writing Custom External Configuration Suppliers

Supplier implementations must conform to the brooklyn.config.external.ExternalConfigSupplier interface, which is very
simple:

```java
String getName();
String get(String key);
```

Classes implementing this interface can be placed in the `lib/dropins` folder of Brooklyn, and then the supplier
defined in `brooklyn.cfg` as normal.