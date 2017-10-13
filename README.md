Brooklyn Website and Docs Source
================================

Contributor Workflow
--------------------

The contributor workflow is identical to that used by the main project, with
pull requests and contributor licenses requried. Therefore you should 
familiarise yourself with the standard workflow for Apache Brooklyn:

* [Guide for contributors][CONTRIB]
* [Guide for committers][COMMIT]

[CONTRIB]: https://brooklyn.apache.org/community/how-to-contribute-docs.html
[COMMIT]: https://brooklyn.apache.org/developers/committers/index.html

The documents are written in [Github flavoured Markdown](https://toolchain.gitbook.com/syntax/markdown.html) a superset of Markdown 
which is processed into HTML using [Gitbook](https://github.com/GitbookIO/gitbook). In addition to the standard set of options
and notation available with these platforms, a number of custom plug-ins have been implemented specifically
for the Brooklyn docs. These are detailed in the [contributing to docs](https://brooklyn.apache.org/contributing) doc.  

Workstation Setup
-----------------

First, if you have not already done so, clone the `brooklyn` repository and subprojects
and set up the remotes as described in [Guide for committers][COMMIT].

The Brooklyn documentation uses [Gitbook](https://github.com/GitbookIO/gitbook) to process the site content into HTML. 
This in turn requires `node` and `npm`:
install node from the their [download page](https://nodejs.org/en/) or via yum / apt-get / brew
to manage installations and dependencies.

Once the `node` and `npm` are installed, run this command to install all the required dependencies 
at the correct versions:

```bash
npm install
```
If you are building the PDF documentation, this requires [calibre](http://wkhtmltopdf.org/).
Please refer to the [Gibook documentation](https://toolchain.gitbook.com/ebook.html).

Seeing the Website and Docs
---------------------------

To build the documentation, run this command in this folder:

```bash
npm run build
```

The generated files will be in `_book`.

To build and run a local webserver:

```bash
npm run serve
```

The URL is printed by Gitbook when the server starts,
e.g. http://localhost:4000/ . The server will continue to run until you press Ctrl+C.
Modified files will be detected and regenerated (but that might take up to 40s).

This does *not* generate API docs, Javadoc nor the website.

**To generate PDF**, first follow [these instructions to install ebook-convert](https://toolchain.gitbook.com/ebook.html), then run:

```bash
npm run pdf
```

Preparing for a Release
-----------------------

When doing a release and changing versions:

* Before branching:
  * Change the `brooklyn_stable_version` variable in `_config.yml`
*  In the branch, with `change-version.sh` run (e.g. from `N.SNAPSHOT` to `N`)
  * Ensure the `start/release-notes.md` file is current
* In master, with `change-version.sh` run (e.g. to `N+1-SNAPSHOT`)
  * Clear old stuff in the `start/release-notes.md` file
 
Publishing the Website and Guide
--------------------------------

The Apache website publication process is based around the Subversion repository; 
the generated HTML files must be checked in to Subversion, whereupon an automated process 
will publish the files to the live website.
So, to push changes the live site, you will need to have the website directory checked out 
from the Apache subversion repository. We recommend setting this up as a sibling to your
`brooklyn` git project directory:

    # verify we're in the right location and the site does not already exist
    ls _build/build.sh || { echo "ERROR: you should be in the docs/ directory to run this command" ; exit 1 ; }
    ls ../../brooklyn-site-public > /dev/null && { echo "ERROR: brooklyn-site-public dir already exists" ; exit 1 ; }
    pushd `pwd -P`/../..
    
    svn --non-interactive --trust-server-cert co https://svn.apache.org/repos/asf/brooklyn/site brooklyn-site-public
    
    # verify it
    cd brooklyn-site-public
    ls style/img/apache-brooklyn-logo-244px-wide.png || { echo "ERROR: checkout is wrong" ; exit 1 ; }
    export BROOKLYN_SITE_DIR=`pwd`
    popd
    echo "SUCCESS: checked out site in $BROOKLYN_SITE_DIR"

With this checked out, the `build.sh` script can automatically copy generated files into the right subversion sub-directories
with the `--install` option.  (This assumes the relative structure described above; if you have a different
structure, set BROOKLYN_SITE_DIR to point to the directory as above.  Alternatively you can copy files manually,
using the instructions in `build.sh` as a guide.)

A typical update consists of the following commands (or a subset),
copied to `${BROOKLYN_SITE_DIR-../../brooklyn-site-public}`:

    # ensure svn repo is up-to-date (very painful otherwise)
    cd ${BROOKLYN_SITE_DIR-../../brooklyn-site-public}
    svn up
    cd -

    # versioned guide, safe for snapshots, relative to /v/<version>/
    _build/build.sh guide-version --install

    # main website, if desired, relative to / 
    _build/build.sh website-root --install
    
    # this version as the latest guide, if desired, relative to /v/latest/
    _build/build.sh guide-latest --install
    
(If HTML-Proofer find failures, then fix the links etc. Unfortunately, the javadoc build 
gives a lot of warnings. Fixing those is not part of this activity).

You can then preview the public site of [localhost:4000](http://localhost:4000) with:

    _build/serve-public-site.sh

Next it is recommended to go to the SVN dir and 
review the changes using the usual `svn` commands -- `status`, `diff`, `add`, `rm`, etc.
Note in particular that deleted files need special attention (there is no analogue of
`git add -A`!). Look at deletions carefully, to try to avoid breaking links, but once
you've done that these commands might be useful:

    cd ${BROOKLYN_SITE_DIR-../../brooklyn-site-public}
    svn add * --force
    export DELETIONS=$( svn status | sed -e '/^!/!d' -e 's/^!//' )
    if [ ! -z "${DELETIONS}" ] ; then svn rm ${DELETIONS} ; fi

Then check in the changes (probably picking a better message than shown here):

    svn ci -m 'Update Brooklyn website'

The changes should become live within a few minutes.

SVN commits can be **slow**, particularly if you've regenerated javadoc.
(The date is included in all javadoc files so the commands above will cause *all* javadoc to be updated.)
Use `_build/build.sh guide-version --install --skip-javadoc` to update master while re-using the previously installed javadoc.
That command will fail if javadoc has not been generated for that version.


More Notes on the Code
----------------------

# Versions

Archived versions are kept under `/v/` in the website.  New versions should be added with
the appropriate directory (`_build/build.sh guide-version` above will do this).  
These versions take their own copy of the `style` files so that changes there will not affect future versions.

A list of available versions is in `website/meta/versions.md`.
