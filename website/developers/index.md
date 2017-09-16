---
layout: website-normal
title: Developers
menu_parent: index.md
children:
- code/
- how-to-contribute.md
- committers/
- code-standards.md
- links.md
- env/maven-build.md
- env/ide/
- code/
- tips/
- tips/logging.md
- tips/debugging-remote-brooklyn.md
- { link: "http://github.com/apache/brooklyn", title: "GitHub" }
- { link: "https://brooklyn.apache.org/v/latest/misc/javadoc", title: "Javadoc" }
- { link: 'http://github.com/apache/brooklyn', title: 'GitHub' }
- { link: 'https://issues.apache.org/jira/browse/BROOKLYN', title: 'Bug Tracker (JIRA)' }
---

Hello developers!
These pages are aimed at people who want to get involved with reading, changing, testing and otherwise
working with the bleeding edge Brooklyn code.

<div class="panel panel-danger">
<div class="panel-heading" markdown="1">
#### Caution
</div>
<div class="panel-body" markdown="1">
As these pages contain information about accessing the bleeding edge code and artifacts produced from it,
you should be aware that the code and binaries you will encounter may be unstable.
The Apache Software Foundation has not performed the level of validation and due diligence done
on formally released artifacts.
Proceed only if you understand the potential consequences of using unreleased code
and are comfortable doing so.
</div>
</div>

We heartily welome contributions and new members.
There's nothing official needed to get involved;
simply come say hello somewhere in the [community](../community/index.html):

- [Mailing lists](../community/mailing-lists.html)
- [IRC channel](../community/irc.html)
- [JIRA for bug tracking](https://issues.apache.org/jira/browse/BROOKLYN)

Then [get the code](code/).

When you have a blueprint or an improvement you want to share,
there are a few instructions to note on [how to contribute](how-to-contribute.html).

There are also a number of [development bookmarks](links.html) for the tools we use
(git, jenkins, jira).


{% comment %}
TODO

The Developer Guide contains information on working with the Brooklyn codebase.

Of particular note to people getting started, there is:

* Help with Maven
* Help with Git
* Help setting up IDE's

And for the Brooklyn codebase itself, see:

* Project structure
* Areas of Special Hairiness

(All links are TODO.)
{% endcomment %}

{% include list-children.html %}
