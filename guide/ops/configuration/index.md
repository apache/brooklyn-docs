---
title_in_menu: Configuring Brooklyn
title: Brooklyn Configuration and Options
layout: website-normal
children:
- { section: Memory Usage }
- { section: Authentication }
- brooklyn_cfg.md
- https.md
- osgi-configuration.md
- cors.md
---

Apache Brooklyn contains a number of configuration options managed across several files. 
Historically Brooklyn has been configured through a brooklyn.properties file, this changed 
to a [brooklyn.cfg](brooklyn_cfg.html) file when the Karaf release became the default in Brooklyn 0.12.0.

The configurations for [persistence](../persistence/index.html) and [high availability](../high-availability/index.html) are described
elsewhere in this manual.

### Memory Usage

The amount of memory required by Apache Brooklyn process depends on the usage - for example the number of entities/VMs under management.

For a standard Brooklyn deployment, the defaults are to start with 256m, and to grow to 2g of memory. These numbers can be overridden 
by setting the `JAVA_MAX_MEM` and `JAVA_MAX_PERM_MEM` in the `bin/setenv` script:

    export JAVA_MAX_MEM="2G"

Apache Brooklyn stores a task history in-memory using [soft references](http://docs.oracle.com/javase/7/docs/api/java/lang/ref/SoftReference.html). 
This means that, once the task history is large, Brooklyn will continually use the maximum allocated memory. It will 
only expunge tasks from memory when this space is required for other objects within the Brooklyn process.

### Authentication and Security

There are two areas of authentication used in Apache Brooklyn, these are as follows:

* Karaf authentication

Apache Brooklyn uses [Apache Karaf](https://karaf.apache.org) as a core platform, this has user level security and
groups which can be configured as detailed [here](https://karaf.apache.org/manual/latest/security#_users_groups_roles_and_passwords).

* Apache Brooklyn authentication

Users and passwords for Brooklyn can be configured in the brooklyn.cfg as detailed [here](brooklyn_cfg.html#authentication).

### HTTPS Configuration

For information on securing your Apache Brooklyn installation with HTTPS, please refer to the pages on [setting up a certificate and keystore](https.html) and 
[configuring this in Brooklyn](osgi-configuration.html#https-configuration).