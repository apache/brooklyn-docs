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
A recent version of `node` is required:  if you get errors consider updating with 
[`nvm`](http://nvm.sh).

Once the `node` and `npm` are installed, run this command to install all the required dependencies 
at the correct versions:

```bash
npm install
```
If you are building the PDF documentation, this requires [calibre](http://wkhtmltopdf.org/).
Please refer to the [Gibook documentation](https://toolchain.gitbook.com/ebook.html).

Seeing the docs
---------------------------

To build the documentation, run this command in this folder:

```bash
npm run book
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

Seeing the javadoc
---------------------------

To build the javadoc, run this command in this folder:

```bash
npm run javadoc
```

The generated files will be in `_book/misc/javadoc`.

To build and serve the docs and javadocs, first start the local webserver:

```bash
npm run serve
```

then run:

```bash
npm run javadoc
```

Preparing for a Release
-----------------------

When doing a release, there are couple of thing to do first:
* create a release branch `<version>` then:
  * update the following variables in `_config.yml`:
    * `brooklyn_version` to `<version>` you are currently releasing
    * `brooklyn_stable_version` to `<version>` you are currently releasing
    * `path.doc` to `/v/<version>`
  * run `change-version.sh <version>-SNAPSHOT <version>`
* In `master` branch:
  * run `change-version.sh <version>-SNAPSHOT <version+1>-SNAPSHOT`
  * clear old stuff in the `start/release-notes.md` file
 
Publishing the docs and javadoc
--------------------------------

The Apache website publication process is based around the Subversion repository; 
the generated HTML files must be checked in to Subversion, whereupon an automated process 
will publish the files to the live website.
So, to push changes the live site, you will need to have the website directory checked out 
from the Apache subversion repository. We recommend setting this up as a sibling to your
`brooklyn` git project directory:

```bash
# verify we're in the right location and the site does not already exist
ls book.json || { echo "ERROR: you should be in the docs/ directory to run this command" ; exit 1 ; }
ls ../../brooklyn-site-public > /dev/null && { echo "ERROR: brooklyn-site-public dir already exists" ; exit 1 ; }
pushd `pwd -P`/../..

svn --non-interactive --trust-server-cert co https://svn.apache.org/repos/asf/brooklyn/site brooklyn-site-public

# verify it
cd brooklyn-site-public
ls style/img/apache-brooklyn-logo-244px-wide.png || { echo "ERROR: checkout is wrong" ; exit 1 ; }
export BROOKLYN_SITE_DIR=`pwd`
popd
echo "SUCCESS: checked out site in $BROOKLYN_SITE_DIR"
```

With this checked out, a typical update consists of the following commands (or a subset)

```bash
# Ensure svn repo is up-to-date (very painful otherwise)
cd ${BROOKLYN_SITE_DIR-../../brooklyn-site-public}
svn up
cd -

# Build docs and javadocs
npm run build

# Copy files over
mkdir -p $BROOKLYN_SITE_DIR/v/<version>
cp -r _book/ $BROOKLYN_SITE_DIR/v/<version>/

```

Next it is recommended to go to the SVN dir and 
review the changes using the usual `svn` commands -- `status`, `diff`, `add`, `rm`, etc.
Note in particular that deleted files need special attention (there is no analogue of
`git add -A`!). Look at deletions carefully, to try to avoid breaking links, but once
you've done that these commands might be useful:

```bash
cd ${BROOKLYN_SITE_DIR-../../brooklyn-site-public}
svn add * --force
export DELETIONS=$( svn status | sed -e '/^!/!d' -e 's/^!//' )
if [ ! -z "${DELETIONS}" ] ; then svn rm ${DELETIONS} ; fi
```

Then check in the changes (probably picking a better message than shown here):

```bash
svn ci -m 'Update Brooklyn website'
```

The changes should become live within a few minutes.

SVN commits can be **slow**, particularly if you've regenerated javadoc.
(The date is included in all javadoc files so the commands above will cause *all* javadoc to be updated.)
Use `npm run book` to update master while re-using the previously installed javadoc.

More Notes on the Code
----------------------

### Versions

Archived versions are kept under `/v/` in the website.  New versions should be added with the appropriate directory.  
These versions take their own copy of the `style` files so that changes there will not affect future versions.

A list of available versions is in `website/meta/versions.md`.
