An *Entity* is Apache Brooklyn's representation of a software package or service which it can control or interact with.
Some of the entities already available for Apache Brooklyn are listed in the [Brooklyn Catalog](/website/learnmore/catalog).

To list the entities of the application you can use the `entity` or `ent` command:

{% highlight bash %}
$ br application Tomcat entity
{% endhighlight %}
<pre>
Id         Name                Type   
Wx7r1C4e   tomcatServer   org.apache.brooklyn.entity.webapp.tomcat.TomcatServer      
</pre>

This shows one entity is available: `tomcatServer`. Note that this is the name we gave the entity in the YAML in [Launching from a Blueprint](./blueprints.html#launching-from-a-blueprint) on the previous page.

You can get summary information for this entity by providing its name (or ID).

{% highlight bash %}
$ br application Tomcat entity tomcatServer
{% endhighlight %}
<pre>
Id:              Wx7r1C4e   
Name:            tomcatServer   
Status:          RUNNING   
ServiceUp:       true   
Type:            org.apache.brooklyn.entity.webapp.tomcat.TomcatServer   
CatalogItemId:   null   
</pre>

Also you can see the configuration of this entity with the ```config``` command.

{% highlight bash %}
$ br application Tomcat entity tomcatServer config
{% endhighlight %}
<pre>
Key                       Value   
jmx.agent.mode            JMXMP_AND_RMI   
brooklyn.wrapper_app      true   
camp.template.id          yBcQuFZe   
onbox.base.dir            /home/vagrant/brooklyn-managed-processes   
onbox.base.dir.resolved   true   
install.unique_label      TomcatServer_7.0.65   
</pre>