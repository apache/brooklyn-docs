---
title: Get the Code
layout: website-normal
children:
- { path: git-more.md, title: "Forks, Git-Fu, and More" }
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
git submodule foreach 'git checkout master'

mvn clean install
{% endhighlight %}

This will produce an artifact in `brooklyn-dist/dist/brooklyn-dist-0.9.0-SNAPSHOT-dist.tar.gz` <!-- BROOKLYN_VERSION -->
which you can use [in the usual way]({{ site.path.guide }}/start/running.html).
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
This [page](git-more.html) elaborates on potential chaos and pitfalls,
and it provides instructions for setting up an alias `git sup` for this command.


### If You Can't Stand Submodules

[These instructions](git-more.html#not-using-submodules) can help setting up a local environment
which does not rely on submodules.


### Contributing a Small Change

If you're making a small change in one project, consider just using that project.
Whether you use this uber-project or not, to [contribute](../how-to-contribute.html) 
you'll need to follow the usual fork->work->push->pull-request process.

To understand where you might want to make your change,
look at the [code structure]({{ site.path.guide }}/dev/code/structure.html).


### Bigger and Regular Changes

Regular contributors will typically have their own fork for each of the submodule projects,
and will probably want some other settings and tips [as described here](git-more.html).

 
## Next Steps

* See the [detailed Brooklyn & Git guide](git-more.html) to 
  [set up forks](git-more.html#set-up-forks) or [handy git aliases](git-more.html#useful-aliases-and-commands)

* Visit the [Developer Guide]({{ site.path.guide }}/dev/) has information on 
  [project structure]({{ site.path.guide }}/dev/code/structure.html),
  [Maven setup]({{ site.path.guide }}/dev/env/maven-build.html) and more

* Review [How to Contribute](../how-to-contribute.html) 
  to [file your CLA](../how-to-contribute.html#contributor-license-agreement)
  or 
  [project structure]({{ site.path.guide }}/dev/code/structure.html),
  [Maven setup]({{ site.path.guide }}/dev/env/maven-build.html) and more

Where things aren't documented **please ask us** at 
[the brooklyn mailing list](https://mail-archives.apache.org/mod_mbox/brooklyn-dev/)
so we can remedy this!
