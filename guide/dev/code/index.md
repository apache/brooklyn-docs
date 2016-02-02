---
title: Get the Code
layout: website-normal
children:
- submodules.md
- no-submodules.md
---

## The Basics

The Apache Brooklyn source code is available at [GitHub apache/brooklyn](http://github.com/apache/brooklyn),
together with many [`brooklyn-*` sub-module projects](https://github.com/apache?query=brooklyn).
Checkout and build all the submodules with:

{% highlight bash %}
git clone http://github.com/apache/brooklyn/
cd brooklyn
git submodule init
git submodule update --remote --merge --recursive

mvn clean install
{% endhighlight %}

This will produce an artifact in `brooklyn-dist/dist/brooklyn-dist-0.9.0-SNAPSHOT-dist.tar.gz` <!-- BROOKLYN_VERSION -->
which you can use [in the usual way](../../start/running.html).
Some options which may be useful:

* Use `--depth 1` with `git clone` to skip the history (much faster but your `git log` will be incomplete)
* Use `-DskipTests` with `mvn` to skip tests (again much faster but it won't catch failures)
* See below if you don't want to use submodules

Thereafter to update the code in submodules, we strongly recommend doing this:

    git pull && git submodule update --remote --merge --recursive

This merges the latest upstream changes into the current branch of each sub-module on your local machine,
giving nice errors on conflicts.
It's fine also to do branching and pulling in each submodule,
but running `update` without these parameters can cause chaos!
The [submodules](submodules.html) page will elaborate on potential chaos and pitfalls,
and it provides instructions for setting up an alias `git sup` for this command.


### If You Can't Stand Submodules

[These instructions](no-submodules.html) can help setting up a local environment
which does not rely on submodules.


### Contributing a Small Change

If you're making a small change in one project, consider just using that project.
Whether you use this uber-project or not, to [contribute]({{ site.path.website }}/developers/how-to-contribute.html) 
you'll need to follow the usual fork->work->push->pull-request process.

To understand where you might want to make your change,
look at the [code structure](structure.html).


### Bigger and Regular Changes

Regular contributors will typically have their own fork for each of the submodule projects,
and will probably want some other settings and tips [as described here](submodules.html).


## History, Tags, and Workflow

There are branches for each released version and tags for various other milestones.

As described in more detail [here](submodules.html), we primarily use submodule remote branch tracking
rather than submodule SHA1 ID's.

The history prior to `0.9.0` is imported from the legacy `incubator-brooklyn` repo for reference and history only.
Visit that repo to build those versions; they are not intended to build here.
(Although this works:
`mkdir merged ; for x in brooklyn-* ; do pushd $x ; git checkout 0.8.0-incubating ; cp -r * ../merged ; popd ; cd merged ; mvn clean install`.)

 
## Next Steps

If you're interested in building and editing the code, you probably want to become familiar with these:

* [Product structure](structure.html)
* [Maven setup](../env/maven-build.html)
* [IDE setup](../env/ide/)
* [Tests](tests.html)
* [Tips](../tips/)
* [Remote Debugging](../tips/debugging-remote-brooklyn.html)

Where things aren't documented **please ask us** at 
[the brooklyn mailing list](https://mail-archives.apache.org/mod_mbox/brooklyn-dev/)
so we can remedy this!
