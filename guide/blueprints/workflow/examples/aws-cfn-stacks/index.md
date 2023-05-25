---
title: AWS CloudFormation Stack Discovery
title_in_menu: AWS CFN Stacks
layout: website-normal
---

The `update-children` step makes it straightforward to keep an Apache Brooklyn model
in synch with external resources, from a cloud, GitHub or Jira tickets, or any data source you choose.
The Brooklyn blueprint can then be used to attach management logic, including for example
automatically deploying branched resources into ephemeral test environments.

This example shows how CloudFormation stacks in AWS can be synchronized.

Firstly, we define our type to represent discovered stack and be able to refresh `on_update`:

{% highlight yaml %}
{% readj aws-cfn-type.bom %}
{% endhighlight %}

This should be added to the catalog.

We can then deploy our Brooklyn application to discover and monitor stacks: 

{% highlight yaml %}
{% readj aws-discoverer.yaml %}
{% endhighlight %}

Create and delete stacks, and see them update in Brooklyn.
Then consider:

* Modify the `ssh aws` step in the "discoverer" to filter based on your preferred tags.
* Use the `transform ... | merge` operator to combine lists from different regions.
* Add other policies to check for drift on stacks and show failures in AMP if there is drift.
* Create a similar workflow to monitor pull requests using the `gh` CLI;
  then create, update, delete, and track ephemeral test deployments based on those
