---
title: Deploying Blueprints
---


## Launching from a Blueprint

When you first access the web console on [http://127.0.0.1:8081](http://127.0.0.1:8081) you will be greeted by the GUI homepage
comprised of:
- the quick launch panel
- links to UI modules

We'll start by deploying an application via a YAML blueprint consisting of the following layers.

- MySQL DB
- Dynamic web application cluster
  - Nginx load balancer
  - Tomcat app server cluster

[![Brooklyn web console, showing the YAML tab of the Add Application dialog.](images/add-blueprint.png)](images/add-blueprint-large.png)

Go the "Blueprint Composer" and switch to the YAML editor view (by clicking on the double horizontal arrows icon on the top right corner)
and copy the blueprint below into the editor. 

But *before* you submit it, modify the YAML to specify the location where the application will be deployed.

!CODEFILE "_my-web-cluster.yaml"

Replace the `location:` element with values for your chosen target environment, for example to use SoftLayer rather than AWS (updating with your own credentials): 

```yaml
location:
  jclouds:softlayer:
    identity: ABCDEFGHIJKLMNOPQRST
    credential: s3cr3tsq1rr3ls3cr3tsq1rr3ls3cr3tsq1rr3l
```

**NOTE**: See __[Locations]({{book.path.docs}}/locations/index.md)__ in the Operations section of the User Guide for instructions on setting up alternate cloud providers, bring-your-own-nodes, or localhost targets, and storing credentials/locations in a file on disk rather than in the blueprint.

With the modified YAML, click on the "Deploy" button. Brooklyn will begin deploying your application and redirect you to the
"Application Inspector". In this screen, you will see your application as "Starting".

[![Brooklyn web console, showing the application starting.](images/app-deploying.png)](images/app-deploying-large.png)

Depending on your choice of location it may take some time for the application nodes to start, the next page describes how you can monitor the progress of the application deployment and verify its successful deployment.

## Launching from the Catalog

Instead of pasting the YAML blueprint each time, it can be added to the Brooklyn Catalog where it will be accessible from the "Quick Launch" panel or "Catalog" and "Blueprint Composer" UI modules.

[![Viewing Catalog entries in Add Application dialog.](images/app-quicklaunch.png)](images/app-quicklaunch-large.png)

<!-- TODO: more detail for adding to catalog? but wait for persistence to be the default, 
     rather than extensively document default.catalog.bom.
     also need to include instructions on stopping (currently in help, including stopping apps) -->

See __[Catalog]({{book.path.docs}}/blueprints/catalog/index.md)__ in the Operations section of the User Guide for instructions on creating a new Catalog entry from your Blueprint YAML.


## Next 

So far we have touched on Brooklyn's ability to *deploy* an application blueprint to a cloud provider.  
The next section will show how to **[Monitor and Manage Applications]({{book.path.docs}}/ops/gui/managing.md)**.
