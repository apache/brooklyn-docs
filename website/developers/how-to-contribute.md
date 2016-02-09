---
layout: website-normal
title: How to Contribute
children:
- { section: Contributor License Agreement, title: CLA }
- { section: Create an Issue in Jira, title: Jira }
- { section: Contributing using GitHub, title: GitHub }
- { section: Reviews }
- { link: code/, title: Get the Code }
- { link: links.html, title: Handy Places }
---

Welcome and thank you for your interest in contributing to Apache Brooklyn! This guide will take you through the
process of making contributions to the Apache Brooklyn code base.

<div class="panel panel-info">
<div class="panel-heading" markdown="1">
#### TL;DR
</div>
<div class="panel-body" markdown="1">

* Pull request to the relevant [GitHub](http://github.com/apache/?query=brooklyn) project
* Sign the [Apache CLA](https://www.apache.org/licenses/#clas) if it's non-trivial.
* For bigger changes, open a [Jira](https://issues.apache.org/jira/browse/BROOKLYN)
   and/or [email the list](../community/mailing-lists.html).

</div>
</div>


### Contributor License Agreement

Apache Brooklyn is licensed under the [Apache License, Version 2.0](https://www.apache.org/licenses/LICENSE-2.0). All
contributions will be under this license, so please read and understand this license before contributing.

For all but the most trivial patches, **we need a Contributor License Agreement for you** on file with the Apache
Software Foundation. Please read the [guide to CLAs](https://www.apache.org/licenses/#clas) to find out how to file a
CLA with the Foundation.


### Join the Community

If it's your first contribution or it's a particularly big or complex contribution, things typically go much more
smoothly when they start off with a conversation. 
Significant changes are normally discussed on the mailing list in any case,
sometimes with a [feature proposal](https://drive.google.com/drive/#folders/0B3XurVLRa7pIUHNFV3NuVVRkRlE/0B3XurVLRa7pIblN4NGRNN2dYUGM/0B3XurVLRa7pIMlZQSUxrdTh4Wmc) document.

Visit our [Community](index.html) page to see how to contact Brooklyners via IRC or email.

### Create an Issue in Jira

The first step is usually to create or find an issue in [Brooklyn's Jira](https://issues.apache.org/jira/browse/BROOKLYN)
for your feature request or fix. For small changes this isn't necessary, but it's good to see if your change fixes an
existing issue anyway.


### Pull Request at GitHub

This is our preferred way for contributing code. Our root GitHub repository is located at
[https://github.com/apache/brooklyn](https://github.com/apache/brooklyn) with most of the code in one of the subprojects.
You can checkout and PR against just one of the projects listed there. See the README in our root repository for information on subprojects.

Your commit messages must properly describes the changes that have been made and their purpose
([here are some guidelines](http://tbaggery.com/2008/04/19/a-note-about-git-commit-messages.html)). If your
contributions fix a Jira issue, then ensure that you reference the issue (like `BROOKLYN-9876`) in the commit message.

Create a pull request (PR) in GitHub for the change you're interested in making.
Include a link to the Jira issue (if it has one) in the PR comment as well as the commit message.

Some good references for working with GitHub are below.  

- [Setting Up Git with GitHub](https://help.github.com/articles/set-up-git)
- [Forking a Repository](https://help.github.com/articles/fork-a-repo)
- [Submitting Pull Requests](https://help.github.com/articles/using-pull-requests)
- [Rebasing your Branch](https://help.github.com/articles/interactive-rebase)

Finally, add a comment in the Jira issue with a link to the pull request so we know the code is ready to be reviewed.

### The Review Process

The Apache Brooklyn community will review your pull request before it is merged. 
If we are slow to respond, please feel free to post a reminder to the PR, Jira issue, IRC channel
or mailing list -- see the [Community](../community/) page to see how to contact us.

During the review process you may be asked to make some changes to your submission. While working through feedback,
it can be beneficial to create new commits so the incremental change is obvious.  This can also lead to a complex set
of commits, and having an atomic change per commit is preferred in the end.  Use your best judgement and work with
your reviewer as to when you should revise a commit or create a new one.

You may also get automated messages on the pull request from the CI running tests
or GitHub determining whether a PR can be merged.
Please keep these up to date to aid reviewers.

A pull request is considered ready to be merged once it gets at lease one +1 from a committer.
At this point your code will be included in the latest Apache Brooklyn.
Congratulations and thank you!


### Contributing without using GitHub

If you prefer to not use GitHub, then that is fine - we are also happy to accept patches attached to a Jira issue.
Our canonical root repository is located at `https://git-wip-us.apache.org/repos/asf/brooklyn.git` with others
in `brooklyn-*.git`; for example:

{% highlight bash %}
$ git clone https://git-wip-us.apache.org/repos/asf/brooklyn-server.git
{% endhighlight %}

When producing patches, please use `git format-patch` or a similar mechanism - this will ensure that you are properly
attributed as the author of the patch when a committer merges it.
The review process will be as with pull requests, except for comments only appearing on the Jira issue.


### Handy Places

If you've not done so, you'll probably want to start by [getting the code](code/).
Once you've done that, you'll find [handy development bookmarks here](links.html).
