---
title: brooklyn.cfg
layout: website-normal
children:
- { section: Quick Setup }
- { section: Locations }
- { section: Java }
- { section: Authentication }
- { section: Entitlements }
- { section: HTTPS Configuration }
---

The file `brooklyn.cfg` is read when Apache Brooklyn starts in order to load any server configuration values. It can be found in the Brooklyn configuration folder. You can check [here](../paths.html) for the location of your Brooklyn configuration folder

## Quick Setup

The most common properties set in this file are for access control. Without this, Brooklyn's 
web-console and REST api will require no authentication.

The simplest way to specify users and passwords is shown below (but see the 
[Authentication](#authentication) section for how to avoid storing passwords in plain text):
 
```properties
brooklyn.webconsole.security.users=admin,bob
brooklyn.webconsole.security.user.admin.password=AdminPassw0rd
brooklyn.webconsole.security.user.bob.password=BobPassw0rd
```

In many cases, it is preferable instead to use an external credentials store such as LDAP.
Information on configuring these is [below](#authentication). 

If coming over a network it is highly recommended additionally to use `https`.
This can be configured with:

```properties
brooklyn.webconsole.security.https.required=true
```

More information, including setting up a certificate, is described [further below](#https-configuration).


## Camp YAML Expressions

Values in `brooklyn.cfg` can use the Camp YAML syntax. Any value starting `$brooklyn:` is 
parsed as a Camp YAML expression.

This allows [externalized configuration]({{ book.path.guide }}/ops/externalized-configuration.html) to be used from 
`brooklyn.cfg`. For example:

```properties
brooklyn.location.jclouds.aws-ec2.identity=$brooklyn:external("vault", "aws-identity")
brooklyn.location.jclouds.aws-ec2.credential=$brooklyn:external("vault", "aws-credential")
```

If for some reason one requires a literal value that really does start with `$brooklyn:` (i.e.
for the value to not be parsed), then this can be achieved by using the syntax below. This 
example returns the property value `$brooklyn:myexample`:

```properties
example.property=$brooklyn:literal("$brooklyn:myexample")
```


## Java

Arbitrary data can be set in the `brooklyn.cfg`.
This can be accessed in java using `ManagementContext.getConfig(KEY)`.


## Authentication

**Security Providers** are the mechanism by which different authentication authorities are plugged in to Brooklyn.
These can be configured by specifying `brooklyn.webconsole.security.provider` equal 
to the name of a class implementing `SecurityProvider`.
An implementation of this could point to Spring, LDAP, OpenID or another identity management system.

The default implementation, `ExplicitUsersSecurityProvider`, reads from a list of users and passwords
which should be specified as configuration parameters e.g. in `brooklyn.cfg`.
This configuration could look like:

```properties
brooklyn.webconsole.security.users=admin
brooklyn.webconsole.security.user.admin.salt=OHDf
brooklyn.webconsole.security.user.admin.sha256=91e16f94509fa8e3dd21c43d69cadfd7da6e7384051b18f168390fe378bb36f9
```

The `users` line should contain a comma-separated list. The special value `*` is accepted to permit all users.

To generate this, the brooklyn CLI can be used:

```bash
brooklyn generate-password --user admin

Enter password: 
Re-enter password: 

Please add the following to your brooklyn.properies:

brooklyn.webconsole.security.users=admin
brooklyn.webconsole.security.user.admin.salt=OHDf
brooklyn.webconsole.security.user.admin.sha256=91e16f94509fa8e3dd21c43d69cadfd7da6e7384051b18f168390fe378bb36f9
```

Alternatively, in dev/test environments where a lower level of security is required,
the syntax `brooklyn.webconsole.security.user.<username>=<password>` can be used for
each `<username>` specified in the `brooklyn.webconsole.security.users` list.

Other security providers available include:

### No one

`brooklyn.webconsole.security.provider=org.apache.brooklyn.rest.security.provider.BlackholeSecurityProvider`
will block all logins (e.g. if not using the web console)

### No security

`brooklyn.webconsole.security.provider=org.apache.brooklyn.rest.security.provider.AnyoneSecurityProvider`
will allow logins with no credentials (e.g. in secure dev/test environments) 

### LDAP

`brooklyn.webconsole.security.provider=org.apache.brooklyn.rest.security.provider.LdapSecurityProvider`
will cause Brooklyn to call to an LDAP server to authenticate users;
The other things you need to set in `brooklyn.cfg` are:

* `brooklyn.webconsole.security.ldap.url` - ldap connection url
* `brooklyn.webconsole.security.ldap.realm` - ldap dc parameter (domain)
* `brooklyn.webconsole.security.ldap.ou` *optional, by default it set to Users* -  ldap ou parameter

**brooklyn.cfg example configuration:**

~~~
brooklyn.webconsole.security.provider=org.apache.brooklyn.rest.security.provider.LdapSecurityProvider
brooklyn.webconsole.security.ldap.url=ldap://localhost:10389/????X-BIND-USER=uid=admin%2cou=system,X-BIND-PASSWORD=secret,X-COUNT-LIMIT=1000
brooklyn.webconsole.security.ldap.realm=example.com
~~~

After you setup the brooklyn connection to your LDAP server, you can authenticate in brooklyn using your cn (e.g. John Smith) and your password.
`org.apache.brooklyn.rest.security.provider.LdapSecurityProvider` searches in the LDAP tree in LDAP://cn=John Smith,ou=Users,dc=example,dc=com

If you want to customize the ldap path or something else which is particular to your LDAP setup you
can extend `LdapSecurityProvider` class or implement from scratch the `SecurityProvider` interface.


## Entitlements

In addition to login access, fine-grained permissions -- including 
seeing entities, creating applications, seeing sensors, and invoking effectors --
can be defined on a per-user *and* per-target (e.g. which entity/effector) basis
using a plug-in **Entitlement Manager**.

This can be set globally with the property:

```properties
brooklyn.entitlements.global=<class>
```

The default entitlement manager is one which responds to per-user entitlement rules,
and understands:

* `root`:  full access, including to the Groovy console
* `user`:  access to everything but actions that affect the server itself. Such actions include the
  Groovy console, stopping the server and retrieving management context configuration.
* `readonly`:  read-only access to almost all information
* `minimal`:  access only to server stats, for use by monitoring systems

These keywords are also understood at the `global` level, so to grant full access to `admin`,
read-only access to `support`, limited access to `metrics` and regular access to `user`
you can write:

```properties
brooklyn.entitlements.global=user
brooklyn.entitlements.perUser.admin=root
brooklyn.entitlements.perUser.support=readonly
brooklyn.entitlements.perUser.metrics=minimal
```

Under the covers this invokes the `PerUserEntitlementManager`, 
with a `default` set (and if not specified `default` defaults to `minimal`); 
so the above can equivalently be written:

```properties
brooklyn.entitlements.global=org.apache.brooklyn.core.mgmt.entitlement.PerUserEntitlementManager
brooklyn.entitlements.perUser.default=user
brooklyn.entitlements.perUser.admin=root
brooklyn.entitlements.perUser.support=readonly
brooklyn.entitlements.perUser.metrics=minimal
```

For more information, see 
[Java: Entitlements]({{ book.path.guide }}/blueprints/java/entitlements.html).
or
[EntitlementManager](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/api/mgmt/entitlement/EntitlementManager.html).



## HTTPS Configuration

See [HTTPS Configuration](https.html) for general information on configuring HTTPS.


