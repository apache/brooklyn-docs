---
layout: website-normal
title: Release branch and set version
navgroup: developers
---

This will allow development to continue on master without affecting the release; it also allows quick-fixes to the
release branch to address last-minute problems (which must of course be merged/cherry-picked back into master later).

Do not use -rc1, -rc2 etc. in version strings. Use the version that will be the actual published version. (The artifacts
that get uploaded to the dist.apache.org/dev will include “-rc1” etc. in the folder name, but the contents will be *as
final*. Therefore, turning the rc into the final is simply a case of taking the rc file and publishing it to the release
folder with the correct name.)

References:

- [Post on general@incubator](https://mail-archives.apache.org/mod_mbox/incubator-general/201409.mbox/%3CCAK2iWdS1H9dkJcSdohky6hFqJdP0XyuhAG%2B%3D1Aspxcjt5RmnJw%40mail.gmail.com%3E)
- [Post on general@incubator](https://mail-archives.apache.org/mod_mbox/incubator-general/201409.mbox/%3CCAOGo0VaEz4cEUbgMgqhh3hiiiubnspiGkQ%3DQv08bOwPqRtzAvQ%40mail.gmail.com%3E)


Create the release branch and set the release version number
------------------------------------------------------------

Create a branch with the same name as the version, based off master:

{% highlight bash %}
git checkout master
git pull --rebase # assumes that the Apache canonical repository is the default upstream for your master - amend if necessary
git submodule update --remote --merge --recursive
for m in $MODULES; do ( cd $m && git checkout master && git checkout -b $VERSION_NAME ); done
{% endhighlight %}

Now change the version numbers in this branch throughout the project using the script `brooklyn-dist/release/change-version.sh` and commit it:

{% highlight bash %}
./brooklyn-dist/release/change-version.sh BROOKLYN $OLD_MASTER_VERSION $VERSION_NAME
# Now inspect the changes and ensure there are no surprises
find . -name "*.bak" -delete
for m in $SUBMODULES; do ( cd $m && git add . && git commit -m "Change version to $VERSION_NAME" ); done
git add $SUBMODULES && git commit -m "Update submodules to $VERSION_NAME"
git add . && git commit -m "Change version to $VERSION_NAME"
{% endhighlight %}

If you are happy with the changes, push them:

{% highlight bash %}
for m in $MODULES; do ( cd $m && git push apache-git $VERSION_NAME ); done
{% endhighlight %}


Update the version on master
----------------------------

The `master` branch will now need updating to refer to the next planned version. (This step is not required if making
a "milestone" release or similar.)

The release notes should be cleared out and the version history augmented with the new version.

Example:

{% highlight bash %}
for m in $MODULES; do ( cd $m && git checkout master ); done
./brooklyn-dist/release/change-version.sh BROOKLYN $OLD_MASTER_VERSION $NEW_MASTER_VERSION
# Now inspect the changes and ensure there are no surprises
{% endhighlight %}

Open `brooklyn-docs/guide/misc/release-notes.md` and `brooklyn-docs/website/meta/versions.md` in your favourite editor and amend.
For release notes this means bumping the reference to the previous version in the "Backwards Compatibility" section
and putting some placeholder text elsewhere.

Then:

{% highlight bash %}
find . -name "*.bak" -delete
for m in $SUBMODULES; do ( cd $m && git add . && git commit -m "Change version to $NEW_MASTER_VERSION" ); done
git add $SUBMODULES && git commit -m "Update submodules to $NEW_MASTER_VERSION"
git add . && git commit -m "Change version to $NEW_MASTER_VERSION"
{% endhighlight %}

If you are happy with the changes, push them:

{% highlight bash %}
for m in $MODULES; do ( cd $m && git push apache-git master ); done
{% endhighlight %}


Switch back to the release branch
---------------------------------

Move back to the release branch:

{% highlight bash %}
for m in $MODULES; do ( cd $m && git checkout $VERSION_NAME ); done
{% endhighlight %}
