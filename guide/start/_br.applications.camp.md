Having created the application, we can find a summary of all deployed applications using:
{% highlight bash %}
$ br application  
{% endhighlight %}

<pre>
 Id         Name     Status    Location   
 hTPAF19s   Tomcat   RUNNING   ajVVAhER
</pre>

```application``` can be shortened to the alias ```app```, for example:
{% highlight bash %}
$ br app  
{% endhighlight %}
<pre>
 Id         Name     Status    Location   
 hTPAF19s   Tomcat   RUNNING   ajVVAhER
</pre>

A full list of abbreviations such as this can be found in the [CLI reference guide](/guide/ops/cli/cli-ref-guide.md#abbreviations){:target="_blank"}.

In the above example the Id `hTPAF19s` and the Name `Tomcat` are shown. You can use either of these handles to monitor and control the application. The Id shown for your application will be different to this but the name should be the same, note that if you are running multiple applications the Name may not be unique.

#### Things we might want to do

<div class="panel-group" id="accordion">
        <div class="panel panel-default">
            <a data-toggle="collapse" data-parent="#accordion" href="#collapseOne"><div class="panel-heading">
                <h4 class="panel-title">
                    Get the application details
                </h4>
            </div></a>
            <div id="collapseOne" class="panel-collapse collapse in">
                <div class="panel-body">
<p>     
Using the name `Tomcat` we can get the application details:
</p>
{% highlight bash %}
$ br application Tomcat
{% endhighlight %}
<pre>
  Id:              hTPAF19s   
  Name:            Tomcat   
  Status:          RUNNING   
  ServiceUp:       true   
  Type:            org.apache.brooklyn.entity.stock.BasicApplication   
  CatalogItemId:   null   
  LocationId:      ajVVAhER   
  LocationName:    FixedListMachineProvisioningLocation:ajVV   
  LocationSpec:    vagrantbyon   
  LocationType:    org.apache.brooklyn.location.byon.FixedListMachineProvisioningLocation  
</pre>        
                </div>
            </div>
        </div>
        <div class="panel panel-default">
            <a data-toggle="collapse" data-parent="#accordion" href="#collapseTwo"><div class="panel-heading">
                <h4 class="panel-title">
                    Explore the hierarchy of all applications
                </h4>
            </div></a>
            <div id="collapseTwo" class="panel-collapse collapse">
                <div class="panel-body">
<p>              
We can explore the management hierarchy of all applications, which will show us the entities they are composed of.
</p>
{% highlight bash %}
$ br tree
{% endhighlight %}
<pre>
|- Tomcat
+- org.apache.brooklyn.entity.stock.BasicApplication
  |- tomcatServer
  +- org.apache.brooklyn.entity.webapp.tomcat.TomcatServer
</pre>
                </div>
            </div>
        </div>
        <div class="panel panel-default">
            <a data-toggle="collapse" data-parent="#accordion" href="#collapseThree"><div class="panel-heading">
                <h4 class="panel-title">
                    View our application's blueprint
                </h4>
            </div></a>
            <div id="collapseThree" class="panel-collapse collapse">
                <div class="panel-body">
<p>
You can view the blueprint for the application again:
</p>
{% highlight bash %}
$ br application Tomcat spec
{% endhighlight %}
<pre>
name: Tomcat
version: 1.0.0-SNAPSHOT
services:
- type: org.apache.brooklyn.entity.webapp.tomcat.TomcatServer
  name: tomcatServer
location:
  ...
</pre>                </div>
            </div>
        </div>
        <div class="panel panel-default">
            <a data-toggle="collapse" data-parent="#accordion" href="#collapseFour"><div class="panel-heading">
                <h4 class="panel-title">
                    View our application's configuration
                </h4>
            </div></a>
            <div id="collapseFour" class="panel-collapse collapse">
                <div class="panel-body">
<p>
You can view the configuration of the application:
</p>
{% highlight bash %}
$ br application Tomcat config
{% endhighlight %}
<pre>
Key                    Value   
camp.template.id       l67i25CM   
brooklyn.wrapper_app   true   
</pre>
                </div>
            </div>
        </div>
    </div>