*Sensors* are properties which show the state of an *entity* and provide a real-time picture of an *entity* within an application.

You can view the sensors available on the application using:

{% highlight bash %}
$ br application Tomcat sensor
{% endhighlight %}
<pre>
Name                       Description                                                                             Value   
service.isUp               Whether the service is active and availability (confirmed and monitored)                true   
service.notUp.indicators   A map of namespaced indicators that the service is not up                               {}   
service.problems           A map of namespaced indicators of problems with a service                               {}   
service.state              Actual lifecycle state of the service                                                   "RUNNING"   
service.state.expected     Last controlled change to service state, indicating what the expected state should be   "running @ 1450356994928 / Thu Dec 17 12:56:34 GMT 2015"
</pre>

To explore sensors on a specific entity use the `sensor` command with an entity specified:

{% highlight bash %}
$ br application Tomcat entity tomcatServer sensor
{% endhighlight %}
<pre>
Name                 Description                                                                                       Value   
download.addon.urls  URL patterns for downloading named add-ons (will substitute things like ${version} automatically) 
download.url         URL pattern for downloading the installer (will substitute things like ${version} automatically)  "http://download.nextag.com/apache/tomcat/tomcat-7/v${version}/bin/apache-tomcat-${version}.tar.gz"   
expandedinstall.dir  Directory for installed artifacts (e.g. expanded dir after unpacking .tgz)                        "/home/vagrant/brooklyn-managed-processes/installs/TomcatServer_7.0.65/apache-tomcat-7.0.65"   
host.address         Host IP address                                                                                   "10.10.10.101"   
host.name            Host name                                                                                         "10.10.10.101"   
host.sshAddress      user@host:port for ssh'ing (or null if inappropriate)                                             "vagrant@10.10.10.101:22"   
host.subnet.address  Host address as known internally in the subnet where it is running (if different to host.name)    "10.10.10.101"   
host.subnet.hostname Host name as known internally in the subnet where it is running (if different to host.name)       "10.10.10.101"   
# etc. etc.
</pre>


To display the value of a selected sensor, give the command the sensor name as an argument

{% highlight bash %}
$ br application Tomcat entity tomcatServer sensor webapp.url  
{% endhighlight %}
<pre>
"http://10.10.10.101:8080/"
</pre>