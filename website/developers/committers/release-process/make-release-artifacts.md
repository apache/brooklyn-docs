---
layout: website-normal
title: Make the release artifacts
navgroup: developers
---

A release script is provided in `brooklyn-dist/release/make-release-artifacts.sh`. This script will prepare all the release artifacts.
It is written to account for several Apache requirements, so you are strongly advised to use it rather than "rolling your own".

The release script will:

- **Create source code and binary distribution artifacts** and place them in a temporary staging directory on your workstation, usually `brooklyn-dist/release/tmp/`.
- **Create Maven artifacts and upload them to a staging repository** located on the Apache Nexus server.

The script has a single required parameter `-r` which is given the release candidate number - so `-r1` will create
release candidate 1 and will name the artifacts appropriately.

The script takes a `-n` parameter to work in *dry run* mode; in this mode, the script will NOT upload Maven artifacts
or commit the release to the Subversion repository. This speeds up the process (the Maven deploy in particular slows
down the build) and will catch any problems such as PGP or javadoc problems much sooner.

{% highlight bash %}
# A dry run to test everything is OK
./brooklyn-dist/release/make-release-artifacts.sh -r$RC_NUMBER -n

# The real build, which will publish artifacts
./brooklyn-dist/release/make-release-artifacts.sh -r$RC_NUMBER
{% endhighlight %}

It will show you the release information it has deduced, and ask yes-or-no if it can proceed. Then you will be prompted
for the passphrase to your GnuPG private key. You should only be asked this question once; the GnuPG agent will cache
the password for the remainder of the build.

Please note that the script will thoroughly clean the Git workspace of all uncommitted and unadded files **even in dry
run mode**. Therefore **you really want to run this against a secondary checkout.** It will wipe `.project` files and
other IDE metadata, and bad things can happen if an IDE tries to write while the script is running. Consider using the
Vagrant configuration provided.

Please note that uploading to the Nexus staging repository is a slow process. Expect this stage of the build to take
2 hours.

The release script will:

1. Prepare a staging directory for the source code release
2. Create .tar.gz and .zip artifacts of the source code
3. Invoke Maven to build the source code (including running unit tests), and deploy artifacts to a Maven remote
   repository
4. Save the .tar.gz and .zip artifacts produced by the build of `brooklyn-dist`
5. For each of the produced files, produce MD5, SHA1, SHA256 and GnuPG signatures

At the end of the script, it will show you the files it has produced and their location.
