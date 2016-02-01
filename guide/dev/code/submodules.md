---
title: Git Submodules
layout: website-normal
---

## Setting Up Forks

If you're contributing regularly, you'll want your submodules to pull from the `apache` repo
and push to your fork.
You'll need to create a fork and the set up your local submodules should then have:

* your fork as the `origin` remote repo
* the Apache github repo as the `upstream` remote repo
* optionally the repo at the Apache git server as the `apache` remote repo  

This can be done automatically with the following commands:

{% highlight bash %}
    hub fork
    git remote add apache https://git-wip-us.apache.org/repos/asf/$x
    for x in brooklyn-* ; do
      pushd $x
      hub fork
      git remote add apache https://git-wip-us.apache.org/repos/asf/$x
      popd
    done
{% endhighlight %}

This requires the command-line tool `hub` [from github](https://github.com/github/hub) (or `sudo npm install -g hub`), 
run in the directory of the uber-project checked out earlier.

You can then pull and update from upstream, push to origin, and create pull requests in each sub-project.
Cross-project changes will require multiple PRs: 
try to minimise these, especially where one depends on another,
and especially especially where two depend on each other -- that is normally a sign of broken backwards compatibility!
Open the PRs in dependency order and assist reviewers by including the URLs of any upstream dependency PRs 
in the dependent PR to help reviewers 
(dependency PRs will then include a "mention" comment of the dependent PR).


## Things You Should Know

Our submodules track **branches**, rather than specific commits,
although due to the way `git` works there are still references to specific commits.

We track `master` for the master branch and the version branch for other official branches, 
starting with `0.9.0`.
We update the uber-project recorded SHA reference to subprojects on releases but not regularly -- 
that just creates noise and is unnecessary with the `--remote` option on `submodule update`.
In fact, `git submodule update --remote --merge` pretty much works well;
the `git sup` alias (below) makes it even easier.

On the other hand, `git status` is not very nice in the uber-project:
it will show a "new commits" message for submodules, 
unless you're exactly at the uber-project's recorded reference.
Ignore these.
It will tell you if you have uncommitted changes, 
but it's not very useful for telling whether you're up to date or if you have newer changes committed 
in the subproject or in your push branch.
If you go in to each sub-project, `git status` works better, but it can be confusing
to track which branch each subproject is one.
A `summary` script is provided below which solves these issues,
showing useful status across all subprojects.


### Pitfalls of Submodules

Submodules can be confusing; if you get stuck the references at the bottom may be useful.
You can also work [without submodules](no-submodules.html).

Some of the things to be careful of are:

* **Don't copy submodule directories.** This doesn't act as you'd expect;
  its `.git` record simply points at the parent project's `.git` folder,
  which in turn points back at it.  So if you copy it and make changes in the copy,
  it's rather surprising where those changes actually get made.
  Worse, `git` doesn't report errors; you'll only notice it when you see files change bizarrely.
  
* **Be careful committing in the uber-project.**
  You can update commit IDs, but if these accidentally point to an ID that isn't committed, 
  everyone else sees errors.
  It's useful to do this on release (and update the target branch then also)
  and maybe occasionally at other milestones but so much at other times as these ID's 
  very quickly become stale on `master`.


### Useful Aliases

{% highlight bash %}
git config --global alias.sup 'submodule update --remote --merge --recursive'
git config --global alias.sdiff '!git diff && git submodule foreach "git diff"'
{% endhighlight %}


### Getting a Summary of Submodules

In addition, the `git-summary` script [here]() makes working with submodules much more enjoyable,
simply install and use `git ss` in the uber-project to see the status of each submodule:

{% highlight bash %}
curl https://gist.githubusercontent.com/ahgittin/6399a29df1229a37b092/raw/05f99aa95a5e8eb541bb79c6707324e26fc0f579/git-summary.sh \
  | sudo tee /usr/local/bin/git-summary
sudo chmod 755 /usr/local/bin/git-summary  
git config --global alias.ss '!git-summary ; echo ; git submodule foreach --quiet "git summary"'
{% endhighlight %}


### Other Handy Commands

{% highlight bash %}
# run a git command (eg pull) in each submodule
git submodule foreach 'git pull'

# iterate across submodules in bash, e.g. doing git status
for x in brooklyn-* ; do pushd $x ; git status ; popd ; done
{% endhighlight %}


### Legacy Incubator Pull Requests

If you need to apply code changes made pre-graduation, against the incubator repository,
splitting it up into submodules, it's fairly straightforward:

1. In the incubator codebase, start at its final state, in `master`.
2. `git checkout -b making-a-diff`
3. Merge or rebase the required commits. 
   Ensure conflicts are resolved, but don't worry about commit messages.
4. `git diff > /tmp/diff`
5. Go to the new `brooklyn` uber-project directory.
   Ensure you are at master and all subprojects updated (`git sup`).
6. `patch -p1 < /tmp/diff` 
7. Run `git ss` to inspect the changes.
8. Test it, commit each changed project on a branch and create pull requests.
   Where applicable, record the original author(s) and message(s) in the commit.



## Git Submodule References

* [1] [Git SCM Book](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
* [2] [Medium blog: Mastering Git Submodules](https://medium.com/@porteneuve/mastering-git-submodules-34c65e940407#.r7677prhv)
* [3] `git submodule --help` section on `update`
* [4] [StackOverflow: Git Submodules Branch Tag](http://stackoverflow.com/questions/1777854/git-submodules-specify-a-branch-tag/18797720#18797720)

