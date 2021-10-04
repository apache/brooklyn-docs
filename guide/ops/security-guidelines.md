---
title: Security Guidelines
layout: website-normal
---

## Brooklyn Server

### Web-console and REST API

Users are strongly encouraged to use HTTPS, rather than HTTP.

The use of LDAP is encouraged, rather than basic auth.

Configuration of "entitlements" is encouraged, to lock down access to the REST API for different 
users.


### Brooklyn user

Users are strongly discouraged from running Brooklyn as root.

For production use-cases (i.e. where Brooklyn will never deploy to "localhost"), the user under 
which Brooklyn is running should not have `sudo` rights.


### Persisted State

Use of an object store is recommended (e.g. using S3 compliant or Swift API) - thus making
use of the security features offered by the chosen object store.

File-based persistence is also supported. Permissions of the files will automatically
be 600 (i.e. read-write only by the owner). Care should be taken for permissions of the
relevant mount points, disks and directories.


## Credential Storage

For credential storage, users are strongly encouraged to consider using the "externalised 
configuration" feature. This allows credentials to be retrieved from a store managed by you, 
rather than being stored within YAML blueprints or `brooklyn.cfg`.

A secure credential store is strongly recommended, such as use of 
[HashiCorp's Vault](https://www.vaultproject.io) - see
`org.apache.brooklyn.core.config.external.vault.VaultExternalConfigSupplier`.


## Infrastructure Access

### Cloud Credentials and Access

Users are strongly encouraged to create separate cloud credentials for Brooklyn's API access.

Users are also encouraged to (where possible) configure the cloud provider for only minimal API 
access (e.g. using AWS IAM).

<!--
TODO: We should document the minimum requirements for AWS IAM required by Brooklyn
-->


### VM Image Credentials

Users are strongly discouraged from using hard-coded passwords within VM images. Most cloud 
providers/APIs provide a mechanism to instead set an auto-generated password or to create an 
entry in `~/.ssh/authorized_keys` (prior to the VM being returned by the cloud provider).

If a hard-coded credential is used, then Brooklyn can be configured with this "loginUser" and 
"loginUser.password" (or "loginUser.privateKeyData"), and can change the password and disable 
root login.


### VM Users

It is strongly discouraged to use the root user on VMs being created or managed by Brooklyn.
SSH-ing on the VM should be done on rare cases such as initial Apache Brooklyn setup,
Apache Brooklyn upgrade and other important maintenance occasions.

### SSH keys

Users are strongly encouraged to use SSH keys for VM access, rather than passwords.

This SSH key could be a file on the Brooklyn server. However, a better solution is to use the 
"externalised configuration" to return the "privateKeyData". This better supports upgrading of 
credentials.


## Install Artifact Downloads

When Brooklyn executes scripts on remote VMs to install software, it often requires downloading 
the install artifacts. For example, this could be from an RPM repository or to retrieve `.zip` 
installers.

By default, the RPM repositories will be whatever the VM image is configured with. For artifacts 
to be downloaded directly, these often default to the public site (or mirror) for that software 
product.

Where users have a private RPM repository, it is strongly encouraged to ensure the VMs are 
configured to point at this.

For other artifacts, users should consider hosting these artifacts in their own web-server and 
configuring Brooklyn to use this. See the documentation for 
`org.apache.brooklyn.core.entity.drivers.downloads.DownloadProducerFromProperties`.


## Controlling Sensitive Information

Often it is necessary to include sensitive information such as credentials within blueprints and locations.
Apache Brooklyn provides a secure mechanism for users to protect the integrity of this information, as follows:

* Values should be set in a secure external store such as an HSM, Vault, AWS Secrets Manager, or properties file
* The blueprint should provide a reference to these values in config keys 
  using [externalized configuration](/guide/ops/externalized-configuration.md)
* Config keys where these values are referenced should comply with the naming scheme below,
  where one of the "sensitive-named tokens" is contained in the key name

Externalized configuration allows blueprints to be written such that they do not contain any secure information,
and with the steps above Apache Brooklyn further guarantees that these values of config keys are not stored on disk
as part of the catalog nor as part of an active deployment, they are not written to the log, and they are not
displayed in the UI.  Because the values are needed for blueprint execution, there are still ways that users with
appropriate permissions can discover these values, such as by using them in scripts or using low-level API calls,
so due care should be taken to secure the user entitlements, the Brooklyn server, and the systems under management. 


### Sensitive-Named Fields

Potentially sensitive information is identified heuristically, by default according to a naming scheme
whereby config keys and environment variables are deemed potentially sensitive if they contain any of 
the following "sensitive-named tokens" (case insensitive):

- `password`
- `passwd`
- `credential`
- `secret`
- `private`
- `access.cert`
- `access.key`

This list can be customized by setting `brooklyn.security.sensitive.fields.tokens` in 
`etc/brooklyn.cfg` to a list of strings, e.g. instead of the list above, to treat keys
containing "hidden" or "pass" as potentially sensitive, set:

```
brooklyn.security.sensitive.fields.tokens=[hidden,pass]
```

Brooklyn will suppress the values of potentially sensitive information in many places, as described below,
but to ensure the values are treated as secure it is necessary to follow the naming scheme _and_
supply the values via externalized configuration.


### Preventing Plaintext Values for Sensitive Named Fields

Apache Brooklyn can be configured to disallow plaintext values for potentially sensitive config keys
with the following `/etc/brooklyn.cfg` property:

```
brooklyn.security.sensitive.fields.plaintext.blocked=true
```

With this set, Apache Brooklyn will prevent deployment of blueprints that provide plaintext values in these places, 
forcing users to follow security best practice.  This will apply to potentially sensitive values embedded in a blueprint 
being deployed or in a blueprint from the catalog referenced by a blueprint being deployed.  
This will also block some additions to the catalog where secrets are set as plaintext config
values (including types from the Composer, except in some cases where it is explicitly marked as a "template").

This does not apply to default values specified for parameters or to values supplied via Java,
as it is expected in these contexts that users are less likely to accidentally supply sensitive values in plaintext.

All functions and complex objects, including mechanisms such as `$brooklyn:literal("value")` (to escape at design-time
and evaluate as `value` at runtime), are permitted as values. 
Sensitive field blocking can optionally be further restricted to exclude selected DSL values and complex objects
where the string representation (unresolved `toString`) contains selected tokens or phrases, by using the
`brooklyn.security.sensitive.fields.ext.blocked.phrases` configuration property.
For example to prevent the usage of the `literal` DSL function anywhere in a supplied expression, 
the following setting can be used: 

```
brooklyn.security.sensitive.fields.ext.blocked.phrases = [ "$brooklyn:literal" ]
```

### Scripts, Sensors, and other Blueprint Execution Considerations

When blueprints are executing, they will by design have access to the sensitive values,
so authors should be careful to limit their usage and maintain the security around these values.
In particular:

* The sensitive-name scheme should be followed for all parameters which might contain the sensitive value,
  and these should refer to sensitive-named configuration properties which refer to an external provider
* When needed for a script, sensitive value should be should be passed as environment variables
  following the sensitive-name scheme, taking their values by referring to sensitive configuration properties, 
  and the values should not be output by the script
* Sensitive values should not be used in template files, sensors, tags, task result, or any other places 
  where the value might be returned in the UI or the logs

If these steps are not followed, the security afforded by the externalized configuration might be compromised.


### Logging


Log messages which may contain sensitive information are normally logged at TRACE level.

Logging should configured such that TRACE is excluded or appropriately secured
to prevent sensitive values from being compromised.
A commented sample configuration for enabling TRACE logging is available in
the `org.ops4j.pax.logging.cfg` logging configuration file.
With this configuration enabled, all TRACE log entries are written to the `brooklyn.trace.log` file.

Blueprint source code and some activity may be logged at DEBUG level or higher,
so, as per above, secrets should not be included in plain text in blueprints
unless the Apache Brooklyn environment and its logs are appropriately secured.

If it is desired to suppress information that is logged at DEBUG or higher level,
which should not ordinarily be needed but may be desired on occasion,
this can be done by setting filter(s) and/or appender(s) on the appropriate logging category in
`org.ops4j.pax.logging.cfg`. Some of the categories (or individual sub-categories of these)
which may be relevant for exclusion or higher security are:

* `org.apache.brooklyn.core.typereg`:
  resolution of bundles and registration of types
* `org.apache.brooklyn.rest.resources`:
  log REST activity, including blueprints deployed
* `org.apache.brooklyn.camp.brooklyn.spi.creation`:
  creation of entities from CAMP
* `org.apache.brooklyn.camp.brooklyn.spi.dsl`:
  resolution of DSL expressions



### Sanitizing Outputs

For security against accidental exposure, plaintext values for sensitive named fields are 
masked in many places in the logs and UI,
typically replaced with a string indicating it is suppressed and supplying a MD5 hash prefix 
(the first 4 bytes / 8 hex chars).
This is so that if you know the value, you can confirm it with high confidence, 
but attackers don't have enough information to
uniquely crack typical-length passwords.

For example, in the logs and in the UI, sensitive information might be displayed as:

    password: <suppressed> (MD5 hash prefix: 0A721B3B)

If you want to confirm the value of the password (in this case `TopSecret`), you can
compute the MD5 hash yourself, e.g. with `echo -n TopSecret | md5`, looking at the first
8 hex digits, and of course taking care to run the command in a secure location!

Note that in some places (eg if plaintext values are embedded in blueprints, contrary to
best practice) masking only applies to values set on the same line after a `:` or `=`.
If the value is supplied on a different line, possibly with comments in between,
the value will not be masked; and in addition, in some places masking is not practical,
such as in the Composer.  Thus security through the sensitive-name scheme alone should
not be relied upon, and where guarantees about the integrity of sensitive information are
required, it must be used alongside the externalized configuration.


