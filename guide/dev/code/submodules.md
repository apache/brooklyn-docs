---
title: Git Submodules
layout: website-normal
---

## Setting Up Forks

If you're contributing regularly, you'll want your submodules to pull from the repo in the Apache GitHub org
and push to your fork.
You'll need to create a fork and then set up your local submodules should then have:

* your fork as the `origin` remote repo
* the Apache GitHub repo as the `upstream` remote repo, 
  optionally with `origin` set as the `push` target (since you can't push to `github.com/apache`)
  and fetch set up to get pull-request branches
* optionally the repo at the Apache git server as the `apache-git` remote repo

Assuming you've checked out from the Apache GitHub repos 
following [the standard instructions](index.html)
(such that that repo is the `origin` remote),
then you can use the following script to automatically do the fork at GitHub and modify your locally-defined remote repos:

{% highlight bash %}
GITHUB_ID=YOUR_ID_HERE

for DIR in . brooklyn-* ; do
  pushd $DIR
  PROJ=$(basename $(pwd))
  echo adding repos for $PROJ

  if curl --fail https://github.com/${GITHUB_ID}/${PROJ} > /dev/null 2>&1 ; then
    # fork exists; rename locally and add fork as origin
    git remote rename origin upstream && git remote add origin git@github.com:${GITHUB_ID}/${PROJ}
  else
    # fork does not exist; create it. this will also do the rename and new remote add as origin
    hub fork
  fi
  git fetch origin
  git fetch upstream

  # configure upstream so pushes go to origin
  git remote set-url --push upstream $(git remote -v | grep origin | grep push | awk '{print $2}')
  # and configure master branch to pull/push against "upstream", i.e. pull from apache/ and push to your repo
  git checkout master && git branch --set-upstream-to upstream/master

  # configure git to fetch pull-request branches
  git config --local --add remote.upstream.fetch '+refs/pull/*/head:refs/remotes/upstream/pr/*'

  # configure the apache-git remote as the canonical Apache git server (not GitHub)
  git remote add apache-git https://git-wip-us.apache.org/repos/asf/${PROJ}

  # and if you want your id as an org set up the same as origin
  git remote add ${GITHUB_ID} git@github.com:${GITHUB_ID}/${PROJ}

  popd
done
{% endhighlight %}

This requires the command-line tool `hub` [from github](https://github.com/github/hub) (or `sudo npm install -g hub`), 
run in the directory of the uber-project checked out earlier.

You should then be able pull and update from upstream, push to origin, and create pull requests in each sub-project.
To check it, run `git remote -v && git submodule foreach "git remote -v"`.


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


### Getting a Summary of Submodules

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

