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

The documents are written in [kramdown](http://kramdown.gettalong.org/syntax.html) a superset of Markdown 
which is processed into HTML using [Jekyll](https://jekyllrb.com/). In addition to the standard set of options
and notation available with these platforms, a number of custom plug-ins have been implemented specifically
for the Brooklyn docs. These are detailed in the [contributing to docs](https://brooklyn.apache.org/contributing) doc.  

Workstation Setup
-----------------

### Manual installation

First, if you have not already done so, clone the `brooklyn` repository and subprojects
and set up the remotes as described in [Guide for committers][COMMIT].

The Brooklyn website uses [Jekyll](https://jekyllrb.com/) to process the site content into HTML. 
This in turn requires Ruby and gems as described in the `Gemfile`:
install [RVM](http://rvm.io/) to manage Ruby installations and sets of Ruby gems.

    \curl -sSL https://get.rvm.io | bash -s stable --auto-dotfiles

Close your shell session and start a new one, to get the new
environment that RVM has configured. Change directory to the location where
this project is (where this file is located).

RVM should detect its configuration inside `Gemfile` and try to configure itself. 
Most likely it will report that the required version of Ruby is not installed,
and it will show the command that you need to run to install the correct version. 
Follow the instructions it shows, typically something like `rvm install ruby-2.1.2`.

Once the correct version of Ruby is installed, change to your home directory
and then change back (`cd ~ ; cd -`).
This will cause RVM to re-load configuration from `Gemfile` with the correct version of Ruby.

Finally, run this command to install all the required Gems 
at the correct versions:

    bundle install

Any time you need to reset your Ruby environment for `jekyll` to run correctly,
go to this directory (or the `_build` subdir) and re-run the above command.

On some platforms there may be some fiddling required before `jekyll` runs without errors,
but the ecosystem is fairly mature and most problems can be resolved with a bit of googling.
Some issues we've encountered are:

 * on Mac, install xcode and its command-line tools
 * if ruby gets confused about versions,
   [clean out your gems](http://judykat.com/ken-judy/force-bundler-rebuild-ruby-rails-gemset/)
 * if `libxml2` fails, set `bundle config build.nokogiri --use-system-libraries` before the install
   (more details [here](http://www.nokogiri.org/tutorials/installing_nokogiri.html))
 * on Ubuntu, `sudo apt-get install libxslt-dev libxml2-dev libcurl4-openssl-dev python-minimal`
 * if you run into problems with 
    ```
    Could not load OpenSSL.
    You must recompile Ruby with OpenSSL support or change the sources in your Gemfile from 'https' to 'http'. Instructions for compiling with OpenSSL using RVM are
    available at rvm.io/packages/openssl.
    ```
 * then try 
    ```
    rvm reinstall 2.1.2 --with-opt-dir=/usr/local --with-openssl-dir=/usr/local/opt/openssl
    ```

 * if you run into trouble with therubyracer and v8 then try (from [link](https://stackoverflow.com/questions/19673714/error-installing-libv8-error-failed-to-build-gem-native-extension))
    ```
    $ gem install libv8 -v '3.16.14.7' -- --with-system-v8
    $ bundle install
    $ gem uninstall libv8
    $ brew install v8
    $ gem install therubyracer
    $ bundle install
    $ gem install libv8 -v '3.16.14.7' -- --with-system-v8
    $ bundle install
    ```

### Using Docker

The project comes with a `Dockerfile` that contains everything you need to build. First, build the docker image

```sh
docker build -t brooklyn:docs-website .
```

Then run the build:

```sh
docker run -it --rm -v ${PWD}:/usr/workspace brooklyn:docs-website "./_build/build.sh website-root"
```

Seeing the Website
------------------

### Manual installation

To build and most of see the documentation, run this command in this folder:

    jekyll serve
    
This will start up a local web server. The URL is printed by Jekyll when the server starts,
e.g. http://localhost:4000/ . The server will continue to run until you press Ctrl+C.
Modified files will be detected and regenerated (but that might take up to 1m).
Add `--no-watch` argument to turn off regeneration, or use `jekyll build` instead
to generate a site in `_site` without a server.

This does <i>not</i> generate API docs and certain other material;
see the notes on `_build/build.sh` below for that.

### Using Docker

Run the following command

```sh
docker run -it --rm -v ${PWD}:/usr/workspace -p4000:4000 brooklyn:docs-website "./_build/build.sh website-root --serve"
```

Project Structure
-----------------

* `/style`: contains JS, CSS, and image resources;
  on the live website, this folder is installed at the root *and* 
  into archived versions of the guide. 
  
* `/_build`: contains build scripts and configuration files,
  and tests for some of the plugins

* `/_plugins`: contains Jekyll plugins which supply tags and generation
  logic for the sites, including links and tables of contents

* `/_layouts`: contains HTML templates used by pages

* `/_includes`: contains miscellaneous content used by templates and pages

Jekyll automatically excludes any file or folder beginning with `_`
from direct processing, so these do *not* show up in the `_site` folder
(except where they are embedded in other files).  

**A word on branches:**  The website lives in the `website` branch whereas the documentation lives in the `master` branch.
The 2 are completely separated micro-site, with their own build tools and process.


Website Structure
-----------------

The two micro-sites above are installed on the live website as follows:

* `/`: contains the website
* `/v/<version>`: contains specific versions of the guide,
  with the special folder `/v/latest` containing the recent preferred stable/milestone version 

The site itself is hosted at `brooklyn.apache.org` with a `CNAME`
record from `brooklyn.io`.

Content is published to the site by updating an 
Apache subversion repository, `brooklyn-site-public` at
`https://svn.apache.org/repos/asf/brooklyn/site`.
See below for more information.


Building the Website
--------------------

For most users, the `jekyll serve` command described above is sufficient to test changes locally.
The main reason to use the build scripts (and to read this section) is to push changes to the server
(requires Apache Brooklyn commit rights), or to test generated content such as API docs.

The build is controlled by config files in `_build/` and accessed through `_build/build.sh`.
There are a number of different builds possible; to list these, run:

    _build/build.sh help

The normal build outputs to `_site/`.  The three builds which are most relevant to updating the live site are:

* **website-root**: to build the website only, in the root

If you which to serve the website locally, you can use the option `--serve` to start a web server, serving the content of `_site/`.
A handy command for testing the live files, analogous to `jekyll serve` 
but with the correct file structure, and then checking links, is:

    _build/build.sh website-root --serve

And to run link-checks quickly (without validating external links), use:

    htmlproof --href_ignore "https?://127.*" --alt_ignore ".*" --disable_external _site



Preparing for a Release
-----------------------

When doing a release and changing versions:

* Before branching:
  * Change the `brooklyn-stable-version` variable in `_config.yml`
  * Update `website/meta/versions.md` with a bit of info on this release
*  In the branch, with `change-version.sh` run (e.g. from `N.SNAPSHOT` to `N`)
  * Ensure the `guide/start/release-notes.md` file is current
  * Build and publish `website-root`, `guide-latest`, and `guide-version`
* In master, with `change-version.sh` run (e.g. to `N+1-SNAPSHOT`)
  * Clear old stuff in the `guide/start/release-notes.md` file
  * Optionally build and public `guide-version`
 

Publishing the Website
----------------------

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

    # main website, if desired, relative to / 
    _build/build.sh website-root --install
    
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

# Plugins

We use some custom Jekyll plugins, in the `_plugins` dir:

* include markdown files inside other files (see, for example, the `*.include.md` files 
  which contain text which is used in multiple other files)
* generate the site structure / menu objects
