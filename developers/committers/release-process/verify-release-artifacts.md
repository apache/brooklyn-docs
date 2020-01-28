---
layout: website-normal
title: Verify the release artifacts
navgroup: developers
---

Below is described a series of "sanity checks" that should be performed before uploading the artifacts to the
pre-release area. They are also useful for community members that want to check the artifact before voting (community
members may also want to check the [list of required software packages](prerequisites.html#software-packages) to ensure
they have the GnuPG installed.

Setup
-----

The scripts below use several environment variables to cut out repetition and enable easy repeatability for the next
release. You should determine the following information and set your environment:

{% highlight bash %}
# The version we are releasing now.
VERSION_NAME=0.10.0

# The release candidate number we are making now.
RC_NUMBER=1

# A reference to your Git repository for Brooklyn
BASE_REPO=~/repos/apache-asf/brooklyn

# The Git commit hash from which the release was made - get this from the release script, or the Release Manager's announcement
GIT_COMMIT=edcf928ee65cc29a84376c822759e468a9f016fe
{% endhighlight %}

Import the PGP keys of the release Managers:

{% highlight bash %}
curl https://dist.apache.org/repos/dist/release/brooklyn/KEYS | gpg2 --import
{% endhighlight %}


Download the artifacts
----------------------

If you've just built the RC, simply go to that directory and skip this step.

If you're verifying a build someone else has made, first download the files including all keys using:

{% highlight bash %}
TEMP_DIR=~/tmp/brooklyn/release/${VERSION_NAME}-rc${RC_NUMBER}
BASE_NAME=apache-brooklyn-${VERSION_NAME}-rc${RC_NUMBER}
BASE_URL=https://dist.apache.org/repos/dist/dev/brooklyn/${BASE_NAME}/

mkdir -p ${TEMP_DIR}
cd ${TEMP_DIR}
curl -s $BASE_URL | \
    grep href | grep -v '\.\.' | \
    sed -e 's@.*href="@'$BASE_URL'@' | \
    sed -e 's@">.*@@' | \
    xargs -n 1 curl -O
{% endhighlight %}

(Alternatively if you have `apache-dist-dev-repo` checked out,
you can do an `svn up` in there and `cd apache-brooklyn-${VERSION_NAME}-rc${RC_NUMBER}`.)

Verify presence of NOTICE & LICENSE
-----------------------------------
Check that all archives are correctly annotated with license information.
Check NOTICE is included:

{% highlight bash %}
for ARCHIVE in $(find * -type f ! \( -name '*.asc' -o -name '*.sha256' \) ); do
  REL_ARCHIVE=${ARCHIVE/-rc?}
  case $ARCHIVE in
    *.tar.gz)
      LIST="tar -tvf"
      PREFIX=${REL_ARCHIVE%.tar.gz}
      ;;
    *.zip)
      LIST="unzip -Zl"
      PREFIX=${REL_ARCHIVE%.zip}
      ;;
    *.rpm)
      LIST="rpm -qlp"
      PREFIX="/opt/brooklyn"
      ;;
    *)
      echo "Unrecognized file type $ARCHIVE. Aborting!"
      exit 1
      ;;
  esac
  $LIST $ARCHIVE | grep "$PREFIX/NOTICE" && \
  $LIST $ARCHIVE | grep "$PREFIX/LICENSE" \
    || { echo "Missing LICENSE or NOTICE in $ARCHIVE. Aborting!"; break; } 
done
{% endhighlight %}

Verify the hashes and signatures of artifacts
---------------------------------------------

Then check the hashes and signatures, ensuring you get a positive message from each one:

{% highlight bash %}
GPG_COMMAND=$((which gpg >> /dev/null && echo gpg) || (which gpg2 >> /dev/null && echo gpg2))

if [ -z "${GPG_COMMAND}" ]; then
    echo "gpg or gpg2 must be installed, exiting"
    exit
fi

for artifact in $(find * -type f ! \( -name '*.asc' -o -name '*.sha256' \) ); do
    shasum -a256 -c ${artifact}.sha256 && \
    $GPG_COMMAND --verify ${artifact}.asc ${artifact} \
      || { echo "Invalid signature for $artifact. Aborting!"; break; }
done
{% endhighlight %}


Verify expanded source archive matches contents of RC tag
---------------------------------------------------------

These commands will compare the contents of the source release to the contents of the equivalent Git commit. Note that
there will be some differences: we cannot release binary files in the source release, so some test artifacts will
appear to be missing from the source release, and the source release excludes the documentation, website and release
scripts.

{% highlight bash %}
cd $BASE_REPO
git checkout $GIT_COMMIT
git clean -d -f -x # WARNING: this will forcibly clean your workspace!

cd $TEMP_DIR
mkdir unpacked-src
# Either:
tar xzf ${BASE_NAME}-src.tar.gz -C unpacked-src/
# or:
unzip ${BASE_NAME}-src.zip -d unpacked-src/
# (or preferably both!)
diff -qr unpacked-src/$BASE_NAME $BASE_REPO
{% endhighlight %}

Check for files with invalid headers in source archive
------------------------------------------------------

{% highlight bash %}
grep -rL "Licensed to the Apache Software Foundation" * | less
{% endhighlight %}

Check for binary files in source archive
-----------------------------------------

Look for files which are created/compiled based on other source files in the distribution.
"Primary" binary files like images are acceptable.

{% highlight bash %}
find . | xargs -n1 file | awk -F $':' ' { t = $1; $1 = $2; $2 = t; print; } ' | sort | less
{% endhighlight %}



Verify the operation of the binary distribution
-----------------------------------------------

{% highlight bash %}
cd $TEMP_DIR
mkdir unpacked-bin
# Either:
tar xzf ${BASE_NAME}-bin.tar.gz -C unpacked-bin/
# or:
unzip ${BASE_NAME}-bin.tar.gz -d unpacked-bin/
# (or preferably both!)
cd unpacked-bin
./bin/brooklyn launch
{% endhighlight %}

Try deploying a simple app, such as the YAML:

{% highlight yaml %}
location: localhost
services:
- type: org.apache.brooklyn.entity.webapp.jboss.JBoss7Server
{% endhighlight %}


Inspect the Maven staging repository
------------------------------------

Go to the Apache Nexus server at [https://repository.apache.org/](https://repository.apache.org/) and log in using the
link in the top right (the credentials are the same as your Git and Jenkins credentials). Go to the "Staging
Repositories" page, and click the repository with the name starting `orgapachebrooklyn`.

Give this a brief inspection to ensure that it looks reasonable. In particular:

- The expected projects are there. (There is no need to do an exhaustive check - but if there is only a couple of
  projects there, then something has clearly gone wrong!)
- The projects contain artifacts with the expected version number.
- The artifacts for a project look reasonable - and there is a `.asc` file (detached PGP cleartext signature) for each
  artifact.


About the sanity check
----------------------

This is the most basic sanity check. This is now suitable to be uploaded to the pre-release area and an announcement
made with voting open. This is then the point for the RM and the community to perform more detailed testing on the RC
artifacts and submit bug reports and votes.


Automated sanity check script available at brooklyn-dist/release/verity_brooklyn_rc.sh


If the sanity check fails
-------------------------

Note the problems causing the failure, and file bug reports, start mailing list discussions etc., as appropriate.

#### For the release manager who was preparing an RC for upload

You should completely discard the defective artifacts.

You will also need to drop the Maven staging repository on Apache's Nexus server: go to the Apache Nexus server at
[https://repository.apache.org/](https://repository.apache.org/) and log in using the link in the top right (the
credentials are the same as your Git and Jenkins credentials). Go to the "Staging Repositories" page, and tick the
repository with the name starting `orgapachebrooklyn`. Click the **Drop** button.
