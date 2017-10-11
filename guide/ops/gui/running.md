---
title: Launching
title_in_menu: Launching
layout: website-normal
menu_parent: index.md
---
# {{ page.title }}

This guide will walk you through connecting to the Brooklyn Server Graphical User Interface and performing various tasks.

For an explanation of common Brooklyn Concepts see the [Brooklyn Concepts Quickstart](../../start/concept-quickstart.md) or see the  full guide in the [Brooklyn Concepts](../../concepts/index.md) chapter of the [User Guide](../../).

This guide assumes that you are using Linux or Mac OS X and that Brooklyn Server will be running on your local system.

## Launch Apache Brooklyn

If you haven't already done so, you will need to start Brooklyn Server using the commands shown below.  
It is not necessary at this time, but depending on what you are going to do, 
you may wish to set up some other configuration options first,
 
* [Security](../configuration/brooklyn_cfg.md)
* [Persistence](../persistence/index.md)

Now start Brooklyn with the following command:

<pre><code class="lang-sh">$ cd apache-brooklyn-{{ book.brooklyn_version }}
$ bin/brooklyn launch</code></pre>

Please refer to the [Server CLI Reference](../server-cli-reference.md) for details of other possible command line options.

Brooklyn will output the address of the management interface:

<pre>
INFO  Starting Brooklyn web-console with no security options (defaulting to no authentication), on bind address <any>
INFO  Started Brooklyn console at http://127.0.0.1:8081/, running classpath://brooklyn.war@
INFO  Persistence disabled
INFO  High availability disabled
INFO  Launched Brooklyn; will now block until shutdown command received via GUI/API (recommended) or process interrupt.
</pre>

_Notice! Before launching Apache Brooklyn, please check the `date` on the local machine.
Even several minutes before or after the actual time could cause problems._

## Connect with Browser

Next, open the web console on [http://127.0.0.1:8081](http://127.0.0.1:8081). 
No applications have been deployed yet, so the "Create Application" dialog opens automatically.

[![Brooklyn web console, showing the YAML tab of the Add Application dialog.](images/add-application-catalog-web-cluster-with-db.png)](images/add-application-catalog-web-cluster-with-db-large.png)

{% if output.name == 'website' %}
## Next
The next section will show how to **[deploy a blueprint](blueprints.md)**.
{% endif %}
