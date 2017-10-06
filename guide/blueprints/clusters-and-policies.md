---
title: Clusters and Policies
layout: website-normal
toc: ../guide_toc.json
categories: [use, guide, defining-applications]
---

Now let's bring the concept of the "cluster" back in.
We could wrap our appserver in the same `DynamicCluster` we used earlier,
although then we'd need to define and configure the load balancer.
But another blueprint, the `ControlledDynamicWebAppCluster`, does this for us.
It takes the same `dynamiccluster.memberspec`, so we can build a fully functional elastic 3-tier
deployment of our `hello-world-sql` application as follows:

!CODEFILE "example_yaml/appserver-clustered-w-db.yaml"


This sets up Nginx as the controller by default, but that can be configured
using the `controllerSpec` key. 
This uses the same [externalized config](../ops/externalized-config.html) 
as in other examples to hide the password.

JBoss is actually the default appserver in the `ControlledDynamicWebAppCluster`,
so because `brooklyn.config` keys in Brooklyn are inherited by default,
the same blueprint can be expressed more concisely as:

!CODEFILE "example_yaml/appserver-clustered-w-db-concise.yaml"
 
The other nicety supplied by the `ControlledDynamicWebAppCluster` blueprint is that
it aggregates sensors from the appserver, so we have access to things like
`webapp.reqs.perSec.windowed.perNode`.
These are convenient for plugging in to policies!
We can set up our blueprint to do autoscaling based on requests per second
(keeping it in the range 10..100, with a maximum of 5 appserver nodes)
as follows: 

!CODEFILE "example_yaml/appserver-w-policy.yaml"

Use your favorite load-generation tool (`jmeter` is one good example) to send a huge
volume of requests against the server and see the policies kick in to resize it.

