---
title: Deploying Blueprints
layout: website-normal
---

Blueprints are descriptors or patterns which describe how Apache Brooklyn should deploy applications. Blueprints are written in [YAML](https://en.wikipedia.org/wiki/YAML){:target="_blank"} and many of the entities available are defined in the __[Brooklyn Catalog](/website/learnmore/catalog/)__.

## Launching from a Blueprint

We'll start by deploying an application with a simple YAML blueprint containing an [Apache Tomcat](https://tomcat.apache.org/){:target="_blank"} server.

{% read _blueprints.camp.md %}


{% read blueprint_locations/_index.md %}


## Deploying the Application

First, log in to brooklyn with the command line interface (CLI) tool by typing:
{% highlight bash %}
$ br login http://localhost:8081/
{% endhighlight %}

To secure the Apache Brooklyn instance, you can add a username and password to Brooklyn's properties file, as described in the User Guide [here](/guide/ops/configuration/brooklyn_cfg.md){:target="_blank"}. 
If this is configured, the login command will require an additional parameter for the userid and will then prompt for a password.

{% read blueprint_locations/_adding_to_catalog.langs.md %}

Now you can create the application with the command below:

{% highlight bash %}
$ br deploy myapp.yaml 
{% endhighlight %}
<pre>
Id:       hTPAF19s   
Name:     Tomcat   
Status:   In progress  
</pre>

Depending on your choice of location it may take some time for the application to start, the next page describes how 
you can monitor the progress of the application deployment and verify if it was successful.

## Next

<div class="started-pdf-exclude" markdown="1">

Having deployed an application, the next step is **[monitoring and managing](managing.md)** it.

</div>
