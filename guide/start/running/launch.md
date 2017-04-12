---
section: Launch Apache Brooklyn
section_type: inline
section_position: 2
---

## Launch Apache Brooklyn

<ul class="nav nav-tabs">
    <li class="active impl-1-tab"><a data-target="#impl-1, .impl-1-tab" data-toggle="tab" href="#">Vagrant</a></li>
    <li class="impl-2-tab"><a data-target="#impl-2, .impl-2-tab" data-toggle="tab" href="#">Centos / RHEL</a></li>
    <li class="impl-3-tab"><a data-target="#impl-3, .impl-3-tab" data-toggle="tab" href="#">OSX / Linux</a></li>
    <li class="impl-4-tab"><a data-target="#impl-4, .impl-4-tab" data-toggle="tab" href="#">Windows</a></li>
</ul>

<div class="tab-content">
<div id="impl-1" class="tab-pane fade in active">

<strong class="hidden started-pdf-include">a) Vagrant</strong>

Now start Apache Brooklyn with the following command:

{% highlight bash %}
$ vagrant up brooklyn
{% endhighlight %}

You can see if Apache Brooklyn launched OK by viewing the log files with the command

{% highlight bash %}
$ vagrant ssh brooklyn --command 'sudo journalctl -n15 -f -u brooklyn'
{% endhighlight %}


</div>
<div id="impl-2" class="tab-pane fade">

<strong class="hidden started-pdf-include">b) Centos / RHEL 7</strong>

Apache Brooklyn should now have been installed and be running as a system service. It can stopped and started with the standard systemctl commands:

{% highlight bash %}
$ systemctl start|stop|restart|status brooklyn
{% endhighlight %}

The application should then output its logs to `/var/log/brooklyn/apache-brooklyn.debug.log` and `/var/log/brooklyn/apache-brooklyn.info.log`.

</div>
<div id="impl-3" class="tab-pane fade">

<strong class="hidden started-pdf-include">c) OSX / Linux</strong>

Now start Apache Brooklyn with the following command:

{% highlight bash %}
$ bin/brooklyn launch
{% endhighlight %}

The application should then output its log into the console and also `apache-brooklyn.debug.log` and `apache-brooklyn.info.log`

</div>
<div id="impl-4" class="tab-pane fade">

<strong class="hidden started-pdf-include">d) Windows</strong>

You can now start Apache Brooklyn by running `c:\Program Files\brooklyn\bin\brooklyn.bat`

The application should then output its log into the console and also `c:\Program Files\brooklyn\apache-brooklyn.debug.log` and `c:\Program Files\brooklyn\apache-brooklyn.info.log`

</div>
</div>

---