---
title: Upgrade
layout: website-normal
---

This guide provides all necessary information to upgrade Apache Brooklyn for both the RPM/DEB and Tarball packages.

## Backwards Compatibility

Apache Brooklyn version 0.12.0 onward runs primarily inside a Karaf container. When upgrading from 0.11.0 or below,
this update changes the mechanisms for launching Brooklyn.
This will impact any custom scripting around the launching of Brooklyn, and the supplying of command line arguments.

Use of the `lib/dropins` and `lib/patch` folders will no longer work (because Karaf does not support that kind of classloading).
Instead, code must be built and installed as [OSGi bundles](https://en.wikipedia.org/wiki/OSGi#Bundles).

## Upgrading

* Use of RPM and DEB is now recommended where possible, rather than the tar.gz. This entirely replaces the previous install.

* CentOS 7.x is recommended over CentOS 6.x (note: the RPM **will not work** on CentOS 6.x)

### Upgrade from Apache Brooklyn 0.12.0 onward

{::options parse_block_html="true" /}

<ul class="nav nav-tabs">
    <li class="active impl-1-tab"><a data-target="#impl-1, .impl-1-tab" data-toggle="tab" href="#">RPM / DEB Packages</a></li>
    <li class="impl-2-tab"><a data-target="#impl-2, .impl-2-tab" data-toggle="tab" href="#">Tarball</a></li>
</ul>

<div class="tab-content">
<div id="impl-1" class="tab-pane fade in active">

1. **Important!** Backup persisted state and custom configuration, in case you need to rollback to a previous version.

   1. By default, persisted state is located at `/var/lib/brooklyn`.
      The `persistenceDir` and `persistenceLocation` are configured in the file `/etc/brooklyn/org.apache.brooklyn.osgilauncher.cfg`.
      The persistence details will be logged in `/var/log/brooklyn/brooklyn.info.log` at startup time.

   2. Configuration files are in `/etc/brooklyn`.

2. Upgrade Apache Brooklyn:

   1. [Download](../misc/download.html) the new RPM/DEB package

   2. Upgrade Apache Brooklyn:

          # CentOS / RHEL
          sudo yum upgrade apache-brooklyn-xxxx.noarch.rpm
          
          # Ubuntu / Debian
          sudo dpkg -i apache-brooklyn-xxxx.all.deb

      If there are conflicts in configuration files (located in `/etc/brooklyn`), the upgrade will behave differently based 
      on the package you are using:
      
      * RPM: the upgrade will keep the previously installed one and save the new version, with the suffix `.rpmsave`.
        You will then need to check and manually resolve those.
      * DEB: the upgrade will ask you what to do.

3. Start Apache Brooklyn:

       # CentOS 7 / RHEL
       sudo systemctl start brooklyn
       # CentOS 6 and older
       sudo initctl start brooklyn
       
       # Ubuntu / Debian
       start brooklyn

   Wait for Brooklyn to be running (i.e. its web-console is responsive)

</div>

<div id="impl-2" class="tab-pane fade">

1. Stop Apache Brooklyn:

       ./bin/stop brooklyn

   If this does not stop it within a few seconds (as checked with `sudo ps aux | grep karaf`), then use `sudo kill <JAVA_PID>`

2. **Important!** Backup persisted state and custom configuration.

   1. By default, persisted state is located at `~/.brooklyn/brooklyn-persisted-state`.
      The `persistenceDir` and `persistenceLocation` are configured in the file `./etc/org.apache.brooklyn.osgilauncher.cfg`.
      The persistence details will be logged in `./log/brooklyn.info.log` at startup time.

   2. Configuration files are in `./etc/`.
      Any changes to these configuration files will need to be re-applied after reinstalling Brooklyn.

3. Install new version of Apache Brooklyn:

   1. [Download](../misc/download.html) the new tarball zip package.
   
   2. Install Brooklyn:

          tar -zxf apache-brooklyn-xxxx.tar.gz
          cd apache-brooklyn-xxxx

4. Restore any changes to the configuration files (see step 2).

5. Validate that the new release works, by starting in "HOT_BACKUP" mode.

   1. Before starting Brooklyn, reconfigure `./etc/org.apache.brooklyn.osgilauncher.cfg` and set `highAvailabilityMode=HOT_BACKUP`.
      This way when Brooklyn is started, it will only read and validate the persisted state and will not write into it.

   2. Start Apache Brooklyn:

          ./bin/start brooklyn

   3. Check whether you have rebind ERROR messages in `./log/brooklyn.info.log`, e.g. `sudo grep -E "WARN|ERROR" /opt/brooklyn/log/brooklyn.debug.log`.
      If you do not have such errors you can proceed.

   4. Stop Apache Brooklyn:

          ./bin/stop brooklyn
 
   5. Change the `highAvailabilityMode` to the default (AUTO) by commenting it out in `./etc/org.apache.brooklyn.osgilauncher.cfg`.

6. Start Apache Brooklyn:

       ./bin/start brooklyn

   Wait for Brooklyn to be running (i.e. its web-console is responsive).

7. Update the catalog, using the br command:

   1. Download the br tool (i.e. from the "CLI Download" link in the web-console).

   2. Login with br: `br login http://localhost:8081 <user> <password>`.

   3. Update the catalog: `br catalog add /opt/brooklyn/catalog/catalog.bom`.

</div>
</div>

### Upgrade from Apache Brooklyn 0.11.0 and below

<ul class="nav nav-tabs">
    <li class="active impl-1-tab"><a data-target="#impl-1, .impl-1-tab" data-toggle="tab" href="#">RPM / DEB Packages</a></li>
    <li class="impl-2-tab"><a data-target="#impl-2, .impl-2-tab" data-toggle="tab" href="#">Tarball</a></li>
</ul>

<div class="tab-content">
<div id="impl-1" class="tab-pane fade in active">

1. Stop Apache Brooklyn:

       # CentOS 7 / RHEL
       sudo systemctl stop brooklyn
       # CentOS6 and older
       sudo initctl stop brooklyn
       
       # Ubuntu / Debian
       stop brooklyn

   If this does not stop it within a few seconds (as checked with `sudo ps aux | grep brooklyn`), then use `sudo kill <JAVA_PID>`.

2. **Important!** Backup persisted state and custom configuration.

   1. By default, persisted state is located at `/opt/brooklyn/.brooklyn/`..
      The `persistenceDir` and `persistenceLocation` are configured in the file `./etc/org.apache.brooklyn.osgilauncher.cfg`.
      The persistence details will be logged in `./log/brooklyn.info.log` at startup time.

   2. Configuration files are in `./etc/`.
      Any changes to these configuration files will need to be re-applied after reinstalling Brooklyn.

3. Delete the existing Apache Brooklyn install:

   1. Remove Brooklyn package:

          # CentOS / RHEL
          sudo yum erase apache-brooklyn
          
          # Ubuntu / Debian
          sudo dpkg -r apache-brooklyn

    2. On CentOS 7 run `sudo systemctl daemon-reload`.

    3. Confirm that Brooklyn is definitely not running (see step 1 above).

    4. Delete the Brooklyn install directory: `sudo rm -r /opt/brooklyn` as well as the Brooklyn log directory:
       `sudo rm -r /var/log/brooklyn/`

4. Make sure you have Java 8.
   By default CentOS images come with JRE6 which is incompatible version for Brooklyn.
   If CentOS is prior to 6.8 upgrade nss: `yum -y upgrade nss`

5. Install new version of Apache Brooklyn:

   1. [Download](../misc/download.html) the new RPM/DEB package.
   
   2. Install Apache Brooklyn:

          # CentOS / RHEL
          sudo yum install apache-brooklyn-xxxx.noarch.rpm
          
          # Ubuntu / Debian
          sudo dpkg -i apache-brooklyn-xxxx.all.deb

6. Restore the persisted state and configuration.

   1. Stop the Brooklyn service:

          # CentOS 7 / RHEL 
          sudo systemctl stop brooklyn
          # CentOS 6 and older
          sudo initctl stop brooklyn
          
          # Ubuntu / Debian
          stop brooklyn

      Confirm that Brooklyn is no longer running (see step 1).

   2. Restore the persisted state directory into `/var/lib/brooklyn` and any changes to the configuration files (see step 2).
      Ensure owner/permissions are correct for the persisted state directory, e.g.:
      `sudo chown -r brooklyn:brooklyn /var/lib/brooklyn`

7. Validate that the new release works, by starting in "HOT_BACKUP" mode.

   1. Before starting Brooklyn, reconfigure `/etc/brooklyn/org.apache.brooklyn.osgilauncher.cfg` and set `highAvailabilityMode=HOT_BACKUP`.
      This way when Brooklyn is started, it will only read and validate the persisted state and will not write into it.

   2. Start Apache Brooklyn:

          # CentOS 7 / RHEL
          sudo systemctl start brooklyn
          # CentOS 6 and older
          sudo initctl start brooklyn
          
          # Ubuntu / Debian
          start brooklyn

   3. Check whether you have rebind ERROR messages in the Brooklyn logs, e.g. `sudo grep -E "Rebind|WARN|ERROR" /var/log/brooklyn/brooklyn.debug.log`.
      If you do not have such errors you can proceed.

   4. Stop Brooklyn:

          # CentOS 7 / RHEL 
          sudo systemctl stop brooklyn
          # CentOS 6 and older
          sudo initctl stop brooklyn
          
          # Ubuntu / Debian
          stop brooklyn
 
   5. Change the `highAvailabilityMode` to the default (AUTO) by commenting it out in `./etc/org.apache.brooklyn.osgilauncher.cfg`.

8. Start Apache Brooklyn:

       # CentOS 7 / RHEL
       sudo systemctl start brooklyn
       # CentOS 6 and older
       sudo initctl start brooklyn
       
       # Ubuntu / Debian
       start brooklyn

   Wait for Brooklyn to be running (i.e. its web-console is responsive).

9. Update the catalog, using the br command:

   1. Download the br tool (i.e. from the "CLI Download" link in the web-console).

   2. Login with br: `br login http://localhost:8081 <user> <password>`.

   3. Update the catalog: `br catalog add /opt/brooklyn/catalog/catalog.bom`.

</div>

<div id="impl-2" class="tab-pane fade">

Same instructions as above.

</div>
</div>

## Rollback

This section applies only with you are using the RPM/DEB packages. To perform a rollback, please follow these instructions:

{% highlight bash %}
# CentOS / RHEL
yum downgrade apache-brooklyn.noarch

# Ubuntu Debian
dpkg -i apache-brooklyn-xxxx.all.deb
{% endhighlight %}

*Note that to downgrade a DEB package is essentially installing a previous version therefore you need to [download](../misc/download.html)
the version you want to downgrade to before hand.*

## How to stop your service

On systemd: 
{% highlight bash %}
systemctl stop brooklyn 
{% endhighlight %}

On upstart: 
{% highlight bash %}
stop brooklyn
{% endhighlight %}

## Web login credentials

* User credentials should now be recorded in [`brooklyn.cfg`](paths.html).

* Brooklyn will still read them from both [`brooklyn.cfg`](paths.html) and `~/.brooklyn/brooklyn.properties`.

* Configure a username/password by modifying [`brooklyn.cfg`](paths.html). An example entry is:
 
{% highlight bash %}
brooklyn.webconsole.security.users=admin
brooklyn.webconsole.security.user.admin.password=password2
{% endhighlight %}

## Persistence

If you have persisted state you wish to rebind to, persistence is now configured in the following files:

* [`brooklyn.cfg`](paths.html)
* [`org.apache.brooklyn.osgilauncher.cfg`](paths.html)

For example, to use S3 for the persisted state, add the following to [`brooklyn.cfg`](paths.html):

{% highlight bash %}
brooklyn.location.named.aws-s3-eu-west-1:aws-s3:eu-west-1
brooklyn.location.named.aws-s3-eu-west-1.identity=<ADD CREDS>
brooklyn.location.named.aws-s3-eu-west-1.credential=<ADD CREDS>
{% endhighlight %}

To continue the S3 example, for the persisted state, add the following to [`org.apache.brooklyn.osgilauncher.cfg`](paths.html):

{% highlight bash %}
persistenceLocation=aws-s3-eu-west-1
persistenceDir=<ADD HERE>
{% endhighlight %}

Apache Brooklyn should be stopped before this file is modified, and then restarted with the new configuration.

***Note that you can not store the credentials (for e.g. aws-s3-eu-west-1) in the catalog because that catalog is stored
in the persisted state. Apache Brooklyn needs to know it in order to read the persisted state at startup time.***

If binding to existing persisted state, an additional command is required to update the existing catalog with the Brooklyn
0.12.0 versions. Assuming Brooklyn has been installed to [`/opt/brooklyn`](paths.html) (as is done by the RPM and DEB):

  {% highlight bash %}
    br catalog add /opt/brooklyn/catalog/catalog.bom
  {% endhighlight %}

All existing custom jars previously added to lib/plugins (e.g. for Java-based entities) need to be converted to OSGi bundles,
and installed in Karaf. The use of the "brooklyn.libraries" section in catalog.bom files will continue to work.
