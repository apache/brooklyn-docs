Effectors are a means by which you can manipulate the entities in an application.  You can list the available effectors for your application using:

{% highlight bash %}
$ br application Tomcat effector
{% endhighlight %}
<pre>
Name            Description                                           Parameters   
restart         Restart the process/service represented by an entity                                                                                                                                      
start           Start the process/service represented by an entity    locations   
stop            Stop the process/service represented by an entity                                                                                                                                         
</pre>

For example, to stop an application, use the ```stop``` effector. This will cleanly shutdown all components in the application and return any cloud machines that were being used.
Note that the three "lifecycle" related effectors, ```start```, ```stop```, and ```restart```, are common to all applications and software process entities in Brooklyn.

You can list the effectors for a specific entity using the command:

{% highlight bash %}
$ br application Tomcat entity tomcatServer effector
{% endhighlight %}
<pre>
Name                              Description                                                                               Parameters   
deploy                            Deploys the given artifact, from a source URL, to a given deployment filename/context     url,targetName   
populateServiceNotUpDiagnostics   Populates the attribute service.notUp.diagnostics, with any available health indicators      
restart                           Restart the process/service represented by an entity                                      restartChildren,restartMachine   
start                             Start the process/service represented by an entity                                        locations   
stop                              Stop the process/service represented by an entity                                         stopProcessMode,stopMachineMode   
undeploy                          Undeploys the given context/artifact                                                      targetName   
</pre>

To view the details for a specific effector, append its name to the command:

{% highlight bash %}
$ br application Tomcat entity tomcatServer effector deploy
{% endhighlight %}
<pre>
Name     Description                                                                             Parameters   
deploy   Deploys the given artifact, from a source URL, to a given deployment filename/context   url,targetName   
</pre>

These effectors can also be invoked by appending ```invoke``` to this command. Some effectors require parameters for their invocation. For example, if we look at the details for ```deploy``` above we can see it requires a url and targetName.

These parameters can be supplied using ```--param parm=value``` or just ```-P parm=value```.

The commands below deploy the Apache Tomcat [hello world example](http://tomcat.apache.org/tomcat-6.0-doc/appdev/index.html){:target="_blank"} to our Tomcat Server. In these commands, a variable is created for the root URL using the appropriate
sensor and the index page html is displayed.

{% highlight bash %}
$ br application Tomcat entity tomcatServer effector deploy invoke -param url=https://tomcat.apache.org/tomcat-6.0-doc/appdev/sample/sample.war -param targetName=sample
$ webapp=$(br application Tomcat entity tomcatServer sensor webapp.url | tr -d '"')
$ curl $webapp/sample/
{% endhighlight %}
<html>
<head>
<title>Sample "Hello, World" Application</title>
</head>
...

**Note** that at present a ```tr``` command is required in the second line below to strip quotation characters from the returned sensor value. 
