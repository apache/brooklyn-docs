---
layout: website-normal
title: Environment variables for the release
navgroup: developers
---

Many example commands in this section using variable names as placeholders for information that will vary between
releases. To allow these example commands to run unmodified, set these environment variables appropriately.

{% highlight bash %}
# The version currently set on the master branch (BROOKLYN_VERSION_BELOW)
OLD_MASTER_VERSION=1.0.0-SNAPSHOT
# The next version to be set on the master branch
NEW_MASTER_VERSION=0.10.0-SNAPSHOT

# The version we are releasing now.
VERSION_NAME=0.9.0

# The release candidate number we are making now.
RC_NUMBER=1

# Modules and submodules - these will come in handy later
SUBMODULES="$( perl -n -e 'if ($_ =~ /path += +(.*)$/) { print $1."\n" }' < .gitmodules )"
MODULES=". ${SUBMODULES}"
{% endhighlight %}

Alternatively, use the command `eval $( ./brooklyn-dist/release/environment.sh )` to set these values automatically.
