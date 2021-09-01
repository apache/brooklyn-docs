
## Locations

Before you can create an application with this configuration,
you need to specify which "location" to use.
Locations in Apache Brooklyn are target environments which Brooklyn can use to deploy applications --
these may be pre-existing servers, virtualization, cloud providers, container environments, or even cloud services.

{% read _header.camp.md %}

Here are some examples of the various location types:

{::options parse_block_html="true" /}

<ul class="nav nav-tabs">
    <li class="active impl-1-tab"><a data-target="#impl-1, .impl-1-tab" data-toggle="tab" href="#">Vagrant</a></li>
    <li class="impl-2-tab"><a data-target="#impl-2, .impl-2-tab" data-toggle="tab" href="#">Clouds</a></li>
    <li class="impl-3-tab"><a data-target="#impl-3, .impl-3-tab" data-toggle="tab" href="#">BYON</a></li>
</ul>

<div class="tab-content">
<div id="impl-1" class="tab-pane fade in active">

The Vagrant configuration described in [Running Apache Brooklyn](running) is the recommended way of setting up a Vagrant environment. 
This configuration comes with four basic servers configured, called `byon1` to `byon4`.

These can be launched by entering the following command into the terminal in the vagrant configuration directory.

{% highlight bash %}
$ vagrant up byon1 byon2 byon3 byon4
{% endhighlight %}

{% read _vagrant.camp.md %}


</div>
<div id="impl-2" class="tab-pane fade">

Apache Brooklyn uses [Apache jclouds](http://jclouds.apache.org/){:target="_blank"} to support a range of cloud locations. More information on the range of providers and configurations is available [here](/guide/locations#clouds){:target="_blank"}.

{% read _jclouds.camp.md %}


</div>
<div id="impl-3" class="tab-pane fade">

The Bring Your Own Nodes (BYON) configuration allows Apache Brooklyn to make use of already available servers. These can be specified by a list of IP addresses with a user and password as shown below. More information including the full range of configuration options is available [here](/guide/locations#byon){:target="_blank"}.

{% read _byon.camp.md %}


</div>
</div>

---

{% read _footer.camp.md %}
