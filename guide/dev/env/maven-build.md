---
layout: website-normal
title: Maven Build
toc: /guide/toc.json
---

## The Basics

The full build requires the following software to be installed:

* Maven (v3.5.4+)
* Java (v1.8)
* Go (v1.6+) [if building the CLI client]
* rpm tools (latest) [if building the dist packages for those platforms]
* deb tools (latest) [if building the dist packages for those platforms]
* docker (latest) [if building the dist package for this platform]

With these in place, you should be able to build everything with a:

{% highlight bash %}
% mvn clean install
{% endhighlight %}

By default, only tarball and zip packages for `brooklyn-dist` will be built. You can enable each dist artifact with the following arguments:
- for CLI client: `-Dcli` (requires `Go`)
- for RPM package: `-Drpm` (requires `rpm tools`)
- for DEB package: `-Ddeb` (requires `deb tools`)
- for docker image: `-Ddocker` (requires `docker`)

Alternatively, you can build everything by using the `release` profile:

{% highlight bash %}
mvn clean install -Prelease
{% endhighlight %}

Other tips:

* Add ``-DskipTests`` to skip tests (builds much faster, but not as safe)

* You may need more JVM memory, e.g. at the command-line (or in `.profile`):

  ``export MAVEN_OPTS="-Xmx1024m -Xms512m"``

* Run ``-PIntegration`` to run integration tests, or ``-PLive`` to run live tests
  ([tests described here](../code/tests.html))

* If building the `rpm` package, you can install rpm tools with: `brew install rpm` for Mac OS, `apt-get install rpm` for Ubuntu, `yum install rpm` for Centos/RHEL.
  On Mac OS you may also need to set `%_tmppath /tmp` in `~/.rpmmacros`.

* If building the `deb` package, you can install deb tools with: `brew install dpkg` for Mac OS, `apt-get install deb` for Ubuntu, `yum install deb` for Centos/RHEL.

* If you're looking at the maven internals, note that many of the settings are inherited from parent projects (see for instance `brooklyn-server/parent/pom.xml`)

* For tips on building within various IDEs, look [here](ide/).


## When the RAT Bites

We use RAT to ensure that all files are compliant to Apache standards.  Most of the time you shouldn't see it or need to know about it, but if it detects a violation, you'll get a message such as:

    [ERROR] Failed to execute goal org.apache.rat:apache-rat-plugin:0.10:check (default) on project brooklyn-parent: Too many files with unapproved license: 1 See RAT report in: /Users/alex/Data/cloudsoft/dev/gits/brooklyn/target/rat.txt -> [Help 1]

If there's a problem, see the file `rat.txt` in the `target` directory of the failed project.  (Maven will show you this link in its output.)

Often the problem is one of the following:

* You've added a file which requires the license header but doesn't have it

  **Resolution:**  Simply copy the header from another file

* You've got some temporary files which RAT things should have headers

  **Resolution:**  Move the files away, add headers, or turn off RAT (see below)

* The project structure has changed and you have stale files (e.g. in a `target` directory)

  **Resolution:**  Remove the stale files, e.g. with `git clean -df` (and if needed a `find . -name target -prune -exec rm -rf {} \;` to delete folders named `target`)

To disable RAT checking on a build, set `rat.ignoreErrors`, e.g. `mvn -Drat.ignoreErrors=true clean install`.  (But note you will need RAT to pass in order for a PR to be accepted!)

If there is a good reason that a file, pattern, or directory should be permanently ignored, that is easy to add inside the root `pom.xml`.


## Other Handy Hints

* The **mvnf** script 
  ([get the gist here](https://gist.github.com/2241800)) 
  simplifies building selected projects, so if you just change something in ``software-webapp`` 
  and then want to re-run the examples you can do:
  
  ``examples/simple-web-cluster% mvnf ../../{software/webapp,usage/all}`` 

## Appendix: Sample Output

A healthy build will look something like the following,
including a few warnings (which we have looked into and
understand to be benign and hard to get rid of them,
although we'd love to if anyone can help!):

{% highlight bash %}
% mvn clean install

...

[INFO] ------------------------------------------------------------------------
[INFO] Reactor Summary for Brooklyn Root 1.0.0-SNAPSHOT:
[INFO]
[INFO] Brooklyn Server Root ............................... SUCCESS [  0.567 s]
[INFO] Brooklyn Parent Project ............................ SUCCESS [  1.552 s]
[INFO] Brooklyn Test Support Utilities .................... SUCCESS [  2.719 s]
[INFO] Brooklyn Logback Includable Configuration .......... SUCCESS [  0.355 s]
[INFO] Brooklyn Common Utilities .......................... SUCCESS [  7.237 s]
[INFO] Brooklyn API ....................................... SUCCESS [  1.229 s]
[INFO] CAMP Server Parent Project ......................... SUCCESS [  0.109 s]
[INFO] CAMP Base .......................................... SUCCESS [  0.893 s]
[INFO] Brooklyn Test Support .............................. SUCCESS [  0.897 s]
[INFO] Brooklyn REST Swagger Apidoc Utilities ............. SUCCESS [  0.733 s]
[INFO] Brooklyn Logback Configuration ..................... SUCCESS [  0.299 s]
[INFO] CAMP Server ........................................ SUCCESS [  1.385 s]
[INFO] Brooklyn Felix Runtime ............................. SUCCESS [  0.534 s]
[INFO] Brooklyn Groovy Utilities .......................... SUCCESS [  0.500 s]
[INFO] Brooklyn Core ...................................... SUCCESS [ 31.521 s]
[INFO] Brooklyn Policies .................................. SUCCESS [  3.556 s]
[INFO] Brooklyn WinRM Software Entities ................... SUCCESS [  1.778 s]
[INFO] Brooklyn Secure JMXMP Agent ........................ SUCCESS [  1.108 s]
[INFO] Brooklyn JMX RMI Agent ............................. SUCCESS [  0.334 s]
[INFO] Brooklyn Jclouds Location Targets .................. SUCCESS [  5.202 s]
[INFO] Brooklyn Software Base ............................. SUCCESS [  6.690 s]
[INFO] Brooklyn CAMP ...................................... SUCCESS [  4.282 s]
[INFO] Brooklyn Launcher Common ........................... SUCCESS [  1.719 s]
[INFO] Brooklyn REST API .................................. SUCCESS [  3.866 s]
[INFO] Brooklyn REST Resources ............................ SUCCESS [  4.475 s]
[INFO] Brooklyn REST Server ............................... SUCCESS [  1.523 s]
[INFO] Brooklyn Launcher .................................. SUCCESS [  2.765 s]
[INFO] Brooklyn Container Location Targets ................ SUCCESS [  2.413 s]
[INFO] Brooklyn Command Line Interface .................... SUCCESS [  2.101 s]
[INFO] Brooklyn Test Framework ............................ SUCCESS [  2.537 s]
[INFO] Brooklyn OSGi init ................................. SUCCESS [  1.517 s]
[INFO] Brooklyn OSGi start ................................ SUCCESS [  1.497 s]
[INFO] Brooklyn Karaf ..................................... SUCCESS [  0.037 s]
[INFO] Jetty config fragment .............................. SUCCESS [  1.381 s]
[INFO] Apache Http Component extension .................... SUCCESS [  0.369 s]
[INFO] Brooklyn Karaf Features ............................ SUCCESS [  0.867 s]
[INFO] Brooklyn Karaf Shell Commands ...................... SUCCESS [  2.625 s]
[INFO] Brooklyn UI :: Parent .............................. SUCCESS [ 25.412 s]
[INFO] Brooklyn UI :: Modularity Server (parent) .......... SUCCESS [  0.138 s]
[INFO] Brooklyn UI :: Modularity Server :: UI Module API .. SUCCESS [  1.085 s]
[INFO] Brooklyn UI :: Modularity Server :: UI Module Registry SUCCESS [  0.802 s]
[INFO] Brooklyn UI :: Modularity Server :: UI Proxy ....... SUCCESS [  0.602 s]
[INFO] Brooklyn UI :: Modularity Server :: UI Metadata Registry SUCCESS [  0.595 s]
[INFO] Brooklyn UI :: Modularity Server :: External UI Modules Registration Hooks SUCCESS [  1.134 s]
[INFO] Brooklyn UI :: Modularity Server :: Features ....... SUCCESS [  2.050 s]
[INFO] Brooklyn UI :: Modules (parent) .................... SUCCESS [  9.488 s]
[INFO] Brooklyn UI :: Modules - UI Utils .................. SUCCESS [  7.689 s]
[INFO] Brooklyn UI :: Modules - Home ...................... SUCCESS [ 34.523 s]
[INFO] Brooklyn UI :: Modules - App inspector ............. SUCCESS [ 37.624 s]
[INFO] Brooklyn UI :: Modules - Blueprint composer ........ SUCCESS [ 39.765 s]
[INFO] Brooklyn UI :: Modules - Blueprint importer ........ SUCCESS [ 31.316 s]
[INFO] Brooklyn UI :: Modules - Catalog ................... SUCCESS [ 32.420 s]
[INFO] Brooklyn UI :: Modules - Location manager .......... SUCCESS [ 30.421 s]
[INFO] Brooklyn UI :: Modules - REST API Docs ............. SUCCESS [ 29.679 s]
[INFO] Brooklyn UI :: Modules - Groovy console ............ SUCCESS [ 27.595 s]
[INFO] Brooklyn UI :: Modules - Logout .................... SUCCESS [ 25.890 s]
[INFO] Brooklyn UI :: Modules - Features .................. SUCCESS [  1.720 s]
[INFO] Brooklyn UI :: Features ............................ SUCCESS [  0.160 s]
[INFO] Brooklyn Library Root .............................. SUCCESS [  0.318 s]
[INFO] Brooklyn CM Chef ................................... SUCCESS [  3.157 s]
[INFO] Brooklyn CM SaltStack .............................. SUCCESS [  1.531 s]
[INFO] Brooklyn CM Ansible ................................ SUCCESS [  1.414 s]
[INFO] Brooklyn CM Integration Root ....................... SUCCESS [  0.172 s]
[INFO] Brooklyn Network Software Entities ................. SUCCESS [  1.458 s]
[INFO] Brooklyn OSGi Software Entities .................... SUCCESS [  1.105 s]
[INFO] Brooklyn Database Software Entities ................ SUCCESS [  2.084 s]
[INFO] Brooklyn Web App Software Entities ................. SUCCESS [  2.996 s]
[INFO] Brooklyn Messaging Software Entities ............... SUCCESS [  3.046 s]
[INFO] Brooklyn NoSQL Data Store Software Entities ........ SUCCESS [  4.885 s]
[INFO] Brooklyn Monitoring Software Entities .............. SUCCESS [  1.048 s]
[INFO] Brooklyn Web App Software Entities ................. SUCCESS [  0.272 s]
[INFO] Brooklyn QA ........................................ SUCCESS [  3.819 s]
[INFO] Brooklyn Examples Aggregator Project ............... SUCCESS [  0.111 s]
[INFO] Brooklyn Examples Aggregator Project - Webapps ..... SUCCESS [  0.158 s]
[INFO] hello-world-webapp Maven Webapp .................... SUCCESS [  0.526 s]
[INFO] hello-world-sql-webapp Maven Webapp ................ SUCCESS [  0.591 s]
[INFO] Brooklyn Simple Web Cluster Example ................ SUCCESS [  1.919 s]
[INFO] Brooklyn Library Karaf integration ................. SUCCESS [  0.087 s]
[INFO] Brooklyn Library Catalog ........................... SUCCESS [  0.316 s]
[INFO] Brooklyn Library Karaf Features .................... SUCCESS [  0.238 s]
[INFO] Brooklyn Downstream Project Parent ................. SUCCESS [  0.082 s]
[INFO] Brooklyn Dist Root ................................. SUCCESS [  0.489 s]
[INFO] Brooklyn All Things ................................ SUCCESS [  1.868 s]
[INFO] Brooklyn Distribution .............................. SUCCESS [  7.541 s]
[INFO] Brooklyn Karaf Distribution Parent ................. SUCCESS [  0.064 s]
[INFO] Brooklyn Karaf Server Configuration ................ SUCCESS [  0.446 s]
[INFO] Brooklyn Dist Karaf Features ....................... SUCCESS [  0.152 s]
[INFO] Brooklyn Karaf Distribution ........................ SUCCESS [ 10.222 s]
[INFO] Brooklyn Karaf pax-exam itest ...................... SUCCESS [  2.030 s]
[INFO] Brooklyn Vagrant Getting Started Environment ....... SUCCESS [  0.190 s]
[INFO] Brooklyn Quick-Start Project Archetype ............. SUCCESS [  0.723 s]
[INFO] Brooklyn Shared Package Files ...................... SUCCESS [  0.328 s]
[INFO] Brooklyn Root ...................................... SUCCESS [  0.439 s]
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  08:21 min
[INFO] Finished at: 2019-04-08T15:52:28+01:00
[INFO] ------------------------------------------------------------------------

{% endhighlight %}
