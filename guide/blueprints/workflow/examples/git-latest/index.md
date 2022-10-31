---
title: Custom Step to Retrieve a Git Repository
title_in_menu: Git Custom Step
layout: website-normal
---

This BOM file can be added to the catalog (download and run `br catalog add <file>`) to
enable a workflow step `ssh-git-latest REPO_URL`, which will connect to a target server over SSH,
then checkout or update a Git repository.

This shows how easy it is to define custom workflow steps,
including your own custom shorthand syntax.

The first time the step is run, the repository will be cloned.
Subsequently it will be updated.
This allows the step to be used flexibly and efficiently, irresepctive of whether it has been run before.
This type of idempotent workflow step is strongly recommended to make workflows easier to work with.

The catalog blueprint is as follows:

{% highlight yaml %}
{% readj git-latest.bom %}
{% endhighlight %}

