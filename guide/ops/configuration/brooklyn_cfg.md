---
title: brooklyn.cfg
layout: website-normal
children:
- { section: Quick Setup }
- { section: Camp YAML Expressions }
- { section: Java }
- { section: Authentication }
- { section: Entitlements }
- { section: HTTPS Configuration }
---

{% include fields.md %}

The file `brooklyn.cfg` is read when Apache Brooklyn starts in order to load any server configuration values. It can be found in the Brooklyn configuration folder. You can check [here](/guide/ops/paths.md) for the location of your Brooklyn configuration folder

## Quick Setup

The most common properties set in this file are for access control. Without this, Brooklyn's 
web-console and REST API will require no authentication.

The simplest way to specify users and passwords is shown below (but see the 
[Authentication](#authentication) section for how to avoid storing passwords in plain text):
 
{% highlight properties %}
brooklyn.webconsole.security.users=admin,bob
brooklyn.webconsole.security.user.admin.password=AdminPassw0rd
brooklyn.webconsole.security.user.bob.password=BobPassw0rd
{% endhighlight %}

In many cases, it is preferable instead to use an external credentials store such as LDAP.
Information on configuring these is [below](#authentication). 

If coming over a network it is highly recommended additionally to use `https`.
This can be configured with:

{% highlight properties %}
brooklyn.webconsole.security.https.required=true
{% endhighlight %}

More information, including setting up a certificate, is described [further below](#https-configuration).


## Camp YAML Expressions

Values in `brooklyn.cfg` can use the Camp YAML syntax. Any value starting `$brooklyn:` is 
parsed as a Camp YAML expression.

This allows [externalized configuration](/guide/ops/externalized-configuration.md) to be used from 
`brooklyn.cfg`. For example:

{% highlight properties %}
brooklyn.location.jclouds.aws-ec2.identity=$brooklyn:external("vault", "aws-identity")
brooklyn.location.jclouds.aws-ec2.credential=$brooklyn:external("vault", "aws-credential")
{% endhighlight %}

If for some reason one requires a literal value that really does start with `$brooklyn:` (i.e.
for the value to not be parsed), then this can be achieved by using the syntax below. This 
example returns the property value `$brooklyn:myexample`:

{% highlight properties %}
example.property=$brooklyn:literal("$brooklyn:myexample")
{% endhighlight %}


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

{% highlight properties %}
brooklyn.webconsole.security.users=admin
brooklyn.webconsole.security.user.admin.salt=OHDf
brooklyn.webconsole.security.user.admin.sha256=91e16f94509fa8e3dd21c43d69cadfd7da6e7384051b18f168390fe378bb36f9
{% endhighlight %}

The `users` line should contain a comma-separated list. The special value `*` is accepted to permit all users.

To generate this, there is a script shipped with Brooklyn:

{% highlight bash %}
./bin/generate-password.sh --user admin

Enter password: 
Re-enter password: 

Please add the following to your etc/brooklyn.cfg:

brooklyn.webconsole.security.users=admin
brooklyn.webconsole.security.user.admin.salt=OHDf
brooklyn.webconsole.security.user.admin.sha256=91e16f94509fa8e3dd21c43d69cadfd7da6e7384051b18f168390fe378bb36f9
{% endhighlight %}

Alternatively, in dev/test environments where a lower level of security is required,
the syntax `brooklyn.webconsole.security.user.<username>=<password>` can be used for
each `<username>` specified in the `brooklyn.webconsole.security.users` list.

Other security providers available include:

### Random Password with Localhost Always Allowed

`brooklyn.webconsole.security.provider=org.apache.brooklyn.rest.security.provider.BrooklynUserWithRandomPasswordSecurityProvider`
will create and log a randomly-created password for use with a user named `brooklyn`. Localhost access will be allowed without a password.
Search in the logs for a message of the form:

`BrooklynUserWithRandomPasswordSecurityProvider [...] Allowing access to web console from localhost or with brooklyn:<password>`


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
* `brooklyn.webconsole.security.ldap.domain_name_regex` *optional* empty by default- regex pattern for the user domain.  
  If it's configured, non-matching login attempts  will be rejected without checking the credentials in the LDAP server.
  If `user_name_regex` is not set, any user in the domain will be tried to authenticate. 
* `brooklyn.webconsole.security.ldap.user_name_regex` *optional* empty by default- regex pattern for usernames. If it's
    configured, non-matching usernames will be rejected without checking the credentials in the LDAP server.
  If `domain_name_regex` is set, only the username matching both, domain and username patterns will be sent to LDAP to 
  authenticate. If `domain_name_regex` is not set, only the username needs to match.
* `brooklyn.webconsole.security.ldap.realm` - ldap dc parameter (domain)
* `brooklyn.webconsole.security.ldap.allowed_realms_regex` - allows multiple realms (domains) that match regex - username must 
  be of form domain\user
* `brooklyn.webconsole.security.ldap.ou` *optional, by default it set to Users* -  ldap ou parameter
* `brooklyn.webconsole.security.ldap.group_config_key` *optional* to be used in combination with the next. Name of the 
  config key prefix for the valid LDAP groups to be mapped to AMP entitlements. If used only mapped groups will be added 
  to the user groups. If empty, user LDAP groups will be ignored.
* `brooklyn.webconsole.security.ldap.fetch_user_group` *optional, by default it set to false* - whether or not the LDAP
  groups for the user should be gathered. If true, the groups will be stored in the user session and the security context
* `brooklyn.webconsole.security.ldap.login_info_log` *optional, by default it set to false* - whether or not the user attempts
  to log in the system must be added to the info log
  **brooklyn.cfg example configuration:**

~~~
brooklyn.webconsole.security.provider=org.apache.brooklyn.rest.security.provider.LdapSecurityProvider
brooklyn.webconsole.security.ldap.url=ldap://localhost:10389/????X-BIND-USER=uid=admin%2cou=system,X-BIND-PASSWORD=secret,X-COUNT-LIMIT=1000
brooklyn.webconsole.security.ldap.realm=example.com
# username regex patterns for DOMAIN\<USERNAME>. `user_name_regex` can be omited 
brooklyn.webconsole.security.ldap.domain_name_regex=DOMAIN
brooklyn.webconsole.security.ldap.user_name_regex=.*
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

{% highlight properties %}
brooklyn.entitlements.global=<class>
{% endhighlight %}

The default entitlement manager is one which responds to per-user entitlement rules,
and understands:

* `root`:  full access, including to the Groovy console
* `poweruser`:  full access, excluding to the Groovy console
* `user`:  access to everything but actions that affect the server itself. Such actions include the
  Groovy console, stopping the server and retrieving management context configuration
* `blueprintAuthor`:  same as user but cannot install bundles containing jar or class files
* `readonly`:  read-only access to almost all information
* `minimal`:  access only to server stats, for use by monitoring systems

These keywords are also understood at the `global` level, so to grant full access to `admin`,
read-only access to `support`, limited access to `metrics` and regular access to `user`
you can write:

{% highlight properties %}
brooklyn.entitlements.global=user
brooklyn.entitlements.perUser.admin=root
brooklyn.entitlements.perUser.support=readonly
brooklyn.entitlements.perUser.metrics=minimal
{% endhighlight %}

Under the covers this invokes the `PerUserEntitlementManager`, 
with a `default` set (and if not specified `default` defaults to `minimal`); 
so the above can equivalently be written:

{% highlight properties %}
brooklyn.entitlements.global=org.apache.brooklyn.core.mgmt.entitlement.PerUserEntitlementManager
brooklyn.entitlements.perUser.default=user
brooklyn.entitlements.perUser.admin=root
brooklyn.entitlements.perUser.support=readonly
brooklyn.entitlements.perUser.metrics=minimal
{% endhighlight %}

For more information, see 
[Java: Entitlements](/guide/blueprints/java/entitlements.md).
or
{% include java_link.html class_name="EntitlementManager" package_path="org/apache/brooklyn/api/mgmt/entitlement" project_subpath="api" %}.


## HTTPS Configuration

See [HTTPS Configuration](https.md) for general information on configuring HTTPS.


## Session configuration

Apache Brooklyn uses a util class, `org.apache.brooklyn.rest.util.MultiSessionAttributeAdapter` for ensuring requests 
in different bundles can get a consistent shared view of the data stored in the session.

To choose the preferred session for a given request you should call one of the static methods `of` in the class.
It will look on the server for a previously marked _preferred session handler_ and return the _preferred session_.
If there is no _preferred session handler_, a new one will be created on the CXF bundle. If there is not a 
_preferred session_ on the _preferred session handler_, a new one will be created. The new elements will be marked as
preferred.    

Any processing that wants to set, get or remove an attribute from the session should use the methods in this class,
as opposed to calling request.getSession().

This class marks as used the session on the other modules by resetting the max inactive interval for avoiding the server
housekeeper service scavenging it due to inactivity. It also allows you to set up a max age time for the sessions, 
otherwise, the default configuration of the Jetty the server will be applied.
 
The default value for the max inactive interval is 3600s but both values can be modified by adding the time in 
seconds as properties on `brooklyn.cfg`:

{% highlight properties %}
org.apache.brooklyn.server.maxSessionAge = 3600
org.apache.brooklyn.server.maxInactiveInterval = 3600
{% endhighlight %}
  
## Login Page

When using a username/password based authentication mechanism, Apache Brooklyn will be default respond with a 401
response code and a [WWW_Authenticate](https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/WWW-Authenticate) header set.  This relies on your browser asking for your basic auth credentials.  
Alternatively you can configure brooklyn to use a login page by setting the following keys:

```
brooklyn.webconsole.security.unauthenticated.endpoints=brooklyn-ui-login
brooklyn.webconsole.security.login.form=brooklyn-ui-login
```

## SSH and Script Defaults

Default values for SSH and script execution behaviour can be set in this file
using the prefix `brooklyn.ssh.config.`, as described in [Locations](/guide/locations#os-setup).


## Certificate Validation

Apache Brooklyn can be configured to perform strict validation for HTTPS using the following keys:

```
brooklyn.https.config.trustAll=false
brooklyn.https.config.laxRedirect=false
```

This is similar but independent of `brooklyn.ssh.config.scripts.ignoreCerts` noted in the previous section.
If set false, Java must be correctly configured with the appropriate trust store in order to connect to HTTPS endpoints.

These can be set globally or on a per-entity / per-location basis.
