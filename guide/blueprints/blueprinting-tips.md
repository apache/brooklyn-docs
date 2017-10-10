---
title: Blueprinting Tips
layout: website-normal
---
# {{ page.title }}

## YAML Recommended

The recommended way to write a blueprint is as a YAML file. This is true both for building
an application out of existing blueprints, and for building new integrations.

The use of Java is reserved for those use-cases where the provisioning or configuration logic 
is very complicated.


## Be Familiar with Brooklyn

Be familiar with the stock entities available in Brooklyn. For example, prove you understand  
the concepts by making a deployment of a cluster of Tomcat servers before you begin writing your 
own blueprints.


## Ask For Help

Ask for help early. The community is keen to help, and also keen to find out what people find 
hard and how people use the product. Such feedback is invaluable for improving future versions.


## Faster Dev-Test

Writing a blueprint is most efficient and simple when testing is fast, and when testing is
done incrementally as features of the blueprint are written.

The slowest stages of deploying a blueprint are usually VM provisioning and downloading/installing
of artifacts (e.g. RPMs, zip files, etc).

Options for speeding up provisioning include those below.

#### Deploying to Bring Your Own Nodes (BYON)

A [BYON location]({{ book.path.guide }}/locations/#byon) can be defined, which avoids the time 
required to provision VMs. This is fast, but has the downside that artifacts installed during a 
previous run can interfere with subsequent runs.

A variant of this is to [use Vagrant]({{ book.path.guide }}/start/running.html) (e.g. with VirtualBox) 
to create VMs on your local machine, and to use these as the target for a BYON location.

These VMs should mirror the target environment as much as possible.


#### Deploying to the "localhost" location

This is fast and simple, but has some obvious downsides:

* Artifacts are installed directly on your desktop/server.

* The artifacts installed during previous runs can interfere with subsequent runs.

* Some entities require `sudo` rights, which must be granted to the user running Brooklyn.


#### Deploying to Clocker

Docker containers provide a convenient way to test blueprints (and also to run blueprints in
production!).

The [Clocker project](http://www.clocker.io) allows the simple setup of Docker Engine(s), and for Docker
containers to be used instead of VMs. For testing, this allows each run to start from a fresh 
container (i.e. no install artifacts from previous runs), while taking advantage of the speed
of starting containers.


#### Local Repository of Install Artifacts

To avoid re-downloading install artifacts on every run, these can be saved to `~/.brooklyn/repository/`.
The file structure is a sub-directory with the entity's simple name, then a sub-directory with the
version number, and then the files to be downloaded. For example, 
`~/.brooklyn/repository/TomcatServer/7.0.56/apache-tomcat-7.0.56.tar.gz`.

If possible, synchronise this directory with your test VMs. 


#### Re-install on BYON

If using BYON or localhost, the install artifacts will by default be installed to a directory like
`/tmp/brooklyn-myname/installs/`. If install completed successfully, then the install stage will 
be subsequently skipped (a marker file being used to indicate completion). To re-test the install 
phase, delete the install directory (e.g. delete `/tmp/brooklyn-myname/installs/TomcatServer_7.0.56/`).

Where installation used something like `apt-get install` or `yum install`, then re-testing the
install phase will require uninstalling these artifacts manually.


## Monitoring and Managing Applications

Think about what it really means for an application to be running. The out-of-the-box default 
for a software process is the lowest common denominator: that the process is still running. 
Consider checking that the app responds over HTTP etc.

If you have control of the app code, then consider adding an explicit health check URL that
does more than basic connectivity tests. For example, can it reach the database, message broker,
and other components that it will need for different operations.


## Writing Composite Blueprints

Write everything in discrete chunks that can be composed into larger pieces. Do not write a single 
mega-blueprint. For example, ensure each component is added to the catalog independently, along 
with a blueprint for the composite app.

Experiment with lots of small blueprints to test independent areas before combining them into the 
real thing.


## Writing Entity Tests

Use the [test framework]({{ book.path.guide }}/blueprints/test/) to write test cases. This will make 
automated (regression) testing easier, and will allow others to easily confirm that the entity 
works in their environment.

If using Maven/Gradle then use the [Brooklyn Maven plugin](https://github.com/brooklyncentral/brooklyn-maven-plugin) 
to test blueprints at build time.


## Custom Entity Development

If writing a custom integration, the following recommendations may be useful:

* Always be comfortable installing and running the process yourself before attempting to automate 
  it.

* For the software to be installed, use its Installation and Admin guides to ensure best practices
  are being followed. Use blogs and advice from experts, when available.

* Where there is a choice of installation approaches, use the approach that is most appropriate for
  production use-cases (even if this is harder to test on locahost). For example, 
  prefer the use of RPMs versus unpacking zip files, and prefer the use of services versus invoking
  a `bin/start` script.

* Ensure every step is scriptable (e.g. manual install does not involve using a text editor to 
  modify configuration files, or clicking on things in a web-console).

* Write scripts (or Chef recipes, or Puppet manifests, etc), and test these by executing manually. 
  Only once these work in isolation, add them to the entity blueprint.

* Externalise the configuration where appropriate. For example, if there is a configuration file
  then include a config key for the URL of the configuration file to use. Consider using FreeMarker
  templating for such configuration files.

* Focus on a single OS distro/version first, and clearly document these assumptions.

* Breakdown the integration into separate components, where possible (and thus develop/test them separately). 
  For example, if deploying a MongoDB cluster then first focus on single-node MongoDB, and then make that
  configurable and composable for a cluster.

* Where appropriate, share the new entity with the Brooklyn community so that it can be reviewed, 
  tested and improved by others in the community!


## Cloud Portability

You get a lot of support out-of-the-box for deploying blueprints to different clouds. The points 
below may also be of help:

* Test (and regression test) on each target cloud.

* Be aware that images on different clouds can be very different. For example, two CentOS 6.6 VMs 
  might have different pre-installed libraries, different default iptables or SE Linux settings,
  different repos, different sudo configuration, etc.

* Different clouds handle private and public IPs differently. One must be careful about which 
  address to advertise to for use by other entities.

* VMs on some clouds may not have a well-configured hostname (e.g. `ping $(hostname)` can fail).

* VMs in different clouds have a different number of NICs. This is important when choosing whether
  to listen on 0.0.0.0 or on a specific NIC.


## Investigating Errors

ALWAYS keep logs when there is an error.

See the [Troubleshooting]({{ book.path.guide }}/ops/troubleshooting/) guide for more information. 
