---
title: Git Submodules
layout: website-normal
---

## Setting Up Forks

If you're contributing or working a lot on a feature, 
you'll probably want your own forks and a slightly different git remote setup.

You can create forks of each Brooklyn repo [in the GitHub UI](https://github.com/apache?query=brooklyn) 
or, if you have the command-line tool `hub` ([described here](https://github.com/github/hub), or `sudo npm install -g hub`),
by running this command:

{% highlight bash %}
hub fork; git submodule foreach 'hub fork'
{% endhighlight %}

The basic clone-and-get-submodules process in the ["Get the code" page](index.html) 
retrieved the upstream repos, but it gave those remotes the name `origin`.
If you have forks, `upstream` is a more accurate name. You can rename the origin remotes with:

{% highlight bash %}
git remote rename origin upstream; git submodule foreach 'git remote rename origin upstream'
{% endhighlight %}

You'll now likely want to add the remote `origin` for your fork:

{% highlight bash %}
if [ -z "$GITHUB_ID" ] ; then echo -n "Enter your GitHub ID id: " ; read GITHUB_ID ; fi
git remote add origin git@github.com:${GITHUB_ID}/apache
git submodule foreach 'git remote add origin git@github.com:${GITHUB_ID}/${name}'
{% endhighlight %}

And if you created the fork in the GitHub UI, you may want to create a remote named by your
GitHub ID as well (if you used `hub` it will have done it for you):

{% highlight bash %}
if [ -z "$GITHUB_ID" ] ; then echo -n "Enter your GitHub ID id: " ; read GITHUB_ID ; fi
git remote add ${GITHUB_ID} git@github.com:${GITHUB_ID}/apache
git submodule foreach 'git remote add ${GITHUB_ID} git@github.com:${GITHUB_ID}/${name}'
{% endhighlight %}

You probably also want the default `push` target to be your repo in the `origin` remote:

{% highlight bash %}
git config remote.pushDefault origin; git submodule foreach 'git config remote.pushDefault origin'
{% endhighlight %}

Optionally, if you're interested in reviewing pull requests,
you may wish to have `git` automatically check out PR branches: 

{% highlight bash %}
git config --local --add remote.upstream.fetch '+refs/pull/*/head:refs/remotes/upstream/pr/*'
git submodule foreach "git config --local --add remote.upstream.fetch '+refs/pull/*/head:refs/remotes/upstream/pr/*'"
git pull ; git submodule foreach 'git pull'
{% endhighlight %}

And also optionally, to set up the official Apache repo as a remote ---
useful if GitHub is slow to update (and required if you're a committer):
 
{% highlight bash %}
git remote add apache-git https://git-wip-us.apache.org/repos/asf/brooklyn
git submodule foreach 'git remote add apache-git https://git-wip-us.apache.org/repos/asf/${name}'
{% endhighlight %}

**That's it.** Test that it's all working by browsing the submodules and issuing `git remote -v` and `git pull` commands. Also see the aliases below.

To work on code in a branch, in any of the submodules, you can simply do the following:

{% highlight bash %}
% git branch my-new-feature-branch upstream/master
% git checkout my-new-feature-branch
(make some commits)
% git push
To https://github.com/your_account/brooklyn.git
 * [new branch]      my-new-feature-branch -> my-new-feature-branch
{% endhighlight %}

Note how the branch is tracking `upstream/master` for the purpose of `git pull`, 
but a `git push` goes to the fork. 
When you're finished, don't forget to go to the UI of your repo to open a pull request.



## Multi-Project Changes

Cross-project changes will require multiple PRs: 
try to minimise these, especially where one depends on another,
and especially especially where two depend on each other -- that is normally a sign of broken backwards compatibility!
Open the PRs in dependency order and assist reviewers by including the URLs of any upstream dependency PRs 
in the dependent PR to help reviewers 
(dependency PRs will then include a "mention" comment of the dependent PR).

For information on reviewing and committing PRs, see [the committer's guide]({{site.path.website}}/developers/committers/merging-contributed-code.html).


## Other Things You Should Know

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

This sets up variants of `pull`, `diff`, and `push` -- called `sup`, `sdiff`, and `spush` -- which act across submodules:

{% highlight bash %}
git config --global alias.sup '!git pull && git submodule update --remote --merge --recursive'
git config --global alias.sdiff '!git diff && git submodule foreach "git diff"'
git config --global alias.spush '!git push && git submodule foreach "git push"'
{% endhighlight %}


#### Getting a Summary of Submodules

The `git-summary` script [here](https://gist.githubusercontent.com/ahgittin/6399a29df1229a37b092) makes working with submodules much more enjoyable,
simply install and use `git ss` in the uber-project to see the status of each submodule:

{% highlight bash %}
curl https://gist.githubusercontent.com/ahgittin/6399a29df1229a37b092/raw/208cf4b3ec2ede77297d2f6011821ae62cf9ac0c/git-summary.sh \
  | sudo tee /usr/local/bin/git-summary
sudo chmod 755 /usr/local/bin/git-summary  
git config --global alias.ss '!git-summary -r'
git config --global alias.so '!git-summary -r -o'
{% endhighlight %}

You'll get output such as:

{% highlight bash %}
brooklyn: master <- upstream/master (up to date)

brooklyn-client: master <- upstream/master (up to date)

brooklyn-dist: master <- upstream/master (up to date)

brooklyn-docs: master <- upstream/master (uncommitted changes only)
  M guide/dev/code/submodules.md

brooklyn-library: master <- upstream/master (up to date)

brooklyn-server: master <- upstream/master (up to date)

brooklyn-ui: test <- origin/test (upstream 2 ahead of master)
  > 62c553e Alex Heneveld, 18 minutes ago: WIP 2
  > 22cd0ad Alex Heneveld, 62 minutes ago: WIP 1
 ?? wip-local-untracked-file
{% endhighlight %}

If you want it to run fast, or you're offline, you can use `git so` to run in off-line mode.
Run `git-summary --help` for more information.


#### Other Handy Commands

{% highlight bash %}
# run a git command (eg pull) in each submodule
git submodule foreach 'git pull'

# iterate across submodules in bash, e.g. doing git status
for x in brooklyn-* ; do pushd $x ; git status ; popd ; done
{% endhighlight %}


### Legacy Incubator Pull Requests

If you need to apply code changes made pre-graduation, against the incubator repository,
splitting it up into submodules, it's fairly straightforward:

1. In the incubator codebase, start at its final state: `cd .../incubator-brooklyn && git checkout master && git pull`
2. Make a branch for your merged changes: `git checkout -b my-branch-merged-master`
3. Merge or rebase the required commits (resolving conflicts; but don't worry about commit messages): `git merge my-branch`
4. Create a patch file: `git diff > /tmp/diff-for-my-branch`
5. Go to the new `brooklyn` uber-project directory.
   Ensure you are at master and all subprojects updated: `cd .../brooklyn/ && git sup`
6. Apply the patch: `patch -p1 < /tmp/diff-for-my-branch` 
7. Inspect the changes: `git ss`
8. Test it, commit each changed project on a branch and create pull requests.
   Where applicable, record the original author(s) and message(s) in the commit.



## Git Submodule References

* [1] [Git SCM Book](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
* [2] [Medium blog: Mastering Git Submodules](https://medium.com/@porteneuve/mastering-git-submodules-34c65e940407#.r7677prhv)
* [3] `git submodule --help` section on `update`
* [4] [StackOverflow: Git Submodules Branch Tag](http://stackoverflow.com/questions/1777854/git-submodules-specify-a-branch-tag/18797720#18797720)

