---
title: Monitoring and Managing Applications
title_in_menu: Monitoring and Managing Applications
layout: website-normal
menu_parent: index.md
children:
- { section: Applications } 
- { section: Entities } 
- { section: Sensors  } 
- { section: Effectors  } 
- { section: Activities } 
---
# {{ page.title }}



So far we have gone through Apache Brooklyn's ability to *deploy* an application blueprint to a location, but this just 
the beginning. Next we will outline how to *manage* the application that has been deployed.

## Applications

Having created the application, we can find a summary of all deployed applications using:
```
$ br application  
 Id         Name     Status    Location   
 hTPAF19s   Tomcat   RUNNING   ajVVAhER
```

`application` can be shortened to the alias `app`, for example:

```
$ br app  
 Id         Name     Status    Location   
 hTPAF19s   Tomcat   RUNNING   ajVVAhER
```

A full list of abbreviations such as this can be found in the [CLI reference guide](../ops/cli/cli-ref-guide.md#abbreviations).

In the above example the Id `hTPAF19s` and the Name `Tomcat` are shown. You can use either of these handles to monitor and control the application. The Id shown for your application will be different to this but the name should be the same, note that if you are running multiple applications the Name may not be unique.

### Things we might want to do

#### Get the application details
  
Using the name `Tomcat` we can get the application details:

```
$ br application Tomcat
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
```

#### Explore the hierarchy of all applications
             
We can explore the management hierarchy of all applications, which will show us the entities they are composed of.

```
$ br tree
|- Tomcat
+- org.apache.brooklyn.entity.stock.BasicApplication
  |- tomcatServer
  +- org.apache.brooklyn.entity.webapp.tomcat.TomcatServer
```

#### View our application's blueprint

You can view the blueprint for the application again:

```
$ br application Tomcat spec
name: Tomcat
location: mylocation
services:
- type: brooklyn.entity.webapp.tomcat.TomcatServer
```

#### View our application's configuration

You can view the configuration of the application:

```
$ br application Tomcat config
Key                    Value   
camp.template.id       l67i25CM   
brooklyn.wrapper_app   true   
```

## Entities

An *Entity* is Apache Brooklyn's representation of a software package or service which it can control or interact with. All of the entities Apache Brooklyn can use are listed in the __[Brooklyn Catalog]({{ book.path.website }}/learnmore/catalog/)__. 

To list the entities of the application you can use the `entity` or `ent` command:

```
$ br application Tomcat entity
Id         Name                Type   
Wx7r1C4e   tomcatServer   org.apache.brooklyn.entity.webapp.tomcat.TomcatServer      
```

This shows one entity is available: `tomcatServer`. Note that this is the name we gave the entity in the YAML in [Launching from a Blueprint](blueprints.md#launching-from-a-blueprint) on the previous page.

You can get summary information for this entity by providing its name (or ID).

```
$ br application Tomcat entity tomcatServer
Id:              Wx7r1C4e   
Name:            tomcatServer   
Status:          RUNNING   
ServiceUp:       true   
Type:            org.apache.brooklyn.entity.webapp.tomcat.TomcatServer   
CatalogItemId:   null   
```

Also you can see the configuration of this entity with the ```config``` command.

```
$ br application Tomcat entity tomcatServer config
Key                       Value   
jmx.agent.mode            JMXMP_AND_RMI   
brooklyn.wrapper_app      true   
camp.template.id          yBcQuFZe   
onbox.base.dir            /home/vagrant/brooklyn-managed-processes   
onbox.base.dir.resolved   true   
install.unique_label      TomcatServer_7.0.65   
```

## Sensors

*Sensors* are properties which show the state of an *entity* and provide a real-time picture of an *entity* within an application.

You can view the sensors available on the application using:

```
$ br application Tomcat sensor
Name                       Description                                                                             Value   
service.isUp               Whether the service is active and availability (confirmed and monitored)                true   
service.notUp.indicators   A map of namespaced indicators that the service is not up                               {}   
service.problems           A map of namespaced indicators of problems with a service                               {}   
service.state              Actual lifecycle state of the service                                                   "RUNNING"   
service.state.expected     Last controlled change to service state, indicating what the expected state should be   "running @ 1450356994928 / Thu Dec 17 12:56:34 GMT 2015"
```

To explore sensors on a specific entity use the `sensor` command with an entity specified:

```
$ br application Tomcat entity tomcatServer sensor
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
```


To display the value of a selected sensor, give the command the sensor name as an argument

```
$ br application Tomcat entity tomcatServer sensor webapp.url  
"http://10.10.10.101:8080/"
```


## Effectors

Effectors are a means by which you can manipulate the entities in an application.  You can list the available effectors for your application using:

```
$ br application Tomcat effector
Name            Description                                           Parameters   
restart         Restart the process/service represented by an entity                                                                                                                                      
start           Start the process/service represented by an entity    locations   
stop            Stop the process/service represented by an entity                                                                                                                                         
```

For example, to stop an application, use the ```stop``` effector. This will cleanly shutdown all components in the application and return any cloud machines that were being used. 
Note that the three "lifecycle" related effectors, ```start```, ```stop```, and ```restart```, are common to all applications and software process entities in Brooklyn.

You can list the effectors for a specific entity using the command:

```
$ br application Tomcat entity tomcatServer effector
Name                              Description                                                                               Parameters   
deploy                            Deploys the given artifact, from a source URL, to a given deployment filename/context     url,targetName   
populateServiceNotUpDiagnostics   Populates the attribute service.notUp.diagnostics, with any available health indicators      
restart                           Restart the process/service represented by an entity                                      restartChildren,restartMachine   
start                             Start the process/service represented by an entity                                        locations   
stop                              Stop the process/service represented by an entity                                         stopProcessMode,stopMachineMode   
undeploy                          Undeploys the given context/artifact                                                      targetName   
```

To view the details for a specific effector, append it's name to the command:

```
$ br application Tomcat entity tomcatServer effector deploy
Name     Description                                                                             Parameters   
deploy   Deploys the given artifact, from a source URL, to a given deployment filename/context   url,targetName   
```

These effectors can also be invoked by appending ```invoke``` to this command. Some effectors require parameters for their invocation. For example, if we look at the details for ```deploy``` above we can see it requires a url and targetName. 

These parameters can be supplied using ```--param parm=value``` or just ```-P parm=value```. 

The commands below deploy the Apache Tomcat [hello world example](http://tomcat.apache.org/tomcat-6.0-doc/appdev/index.html) to our Tomcat Server. In these commands, a variable is created for the root URL using the appropriate
sensor and the index page html is displayed. 

```
$ br application Tomcat entity tomcatServer effector deploy invoke -P url=https://tomcat.apache.org/tomcat-6.0-doc/appdev/sample/sample.war -P targetName=sample
$ webapp=$(br application Tomcat entity tomcatServer sensor webapp.url | tr -d '"')
$ curl $webapp/sample/
    <html>
    <head>
    <title>Sample "Hello, World" Application</title>
    </head>
    ...
```

**Note** that at present a `tr` command is required in the second line below to strip quotation characters from the returned sensor value. 

## Activities

*Activities* are the actions an application or entity takes within Apache Brooklyn. The ```activity``` command allows us to list out these activities. 

To view a list of all activities associated with an entity enter:

```
$ br application Tomcat entity tomcatServer activity
Id         Task                                       Submitted                      Status      Streams   
LtD5P1cb   start                                      Thu Dec 17 15:04:43 GMT 2015   Completed   
l2qo4vTl   provisioning (FixedListMachineProvisi...   Thu Dec 17 15:04:43 GMT 2015   Completed   
wLD764HE   pre-start                                  Thu Dec 17 15:04:43 GMT 2015   Completed    
KLTxDkoa   ssh: initializing on-box base dir ./b...   Thu Dec 17 15:04:43 GMT 2015   Completed   env,stderr,stdin,stdout   
jwwcJWmF   start (processes)                          Thu Dec 17 15:04:43 GMT 2015   Completed        
...
```

To view the details of an individual activity, add its ID to the command. In our case this is `jwwcJWmF`

```
$ br application Tomcat entity tomcatServer activity jwwcJWmF
Id:                  jwwcJWmF   
DisplayName:         start (processes)   
Description:            
EntityId:            efUvVWAw   
EntityDisplayName:   TomcatServer:efUv   
Submitted:           Thu Dec 17 15:04:43 GMT 2015   
Started:             Thu Dec 17 15:04:43 GMT 2015   
Ended:               Thu Dec 17 15:08:59 GMT 2015   
CurrentStatus:       Completed   
IsError:             false   
IsCancelled:         false   
SubmittedByTask:     LtD5P1cb   
Streams:                
DetailedStatus:      "Completed after 4m 16s

No return value (null)"   
```

### Things we might want to do

#### View Input and Output Streams

If an activity has associated input and output streams, these may be viewed by providing the activity scope and
using the commands, "env", "stdin", "stdout", and "stderr".  For example, for the "initializing on-box base dir"
activity from the result of the earlier example,

```
$ br application Tomcat entity tomcatServer act KLTxDkoa stdout
BASE_DIR_RESULT:/home/vagrant/brooklyn-managed-processes:BASE_DIR_RESULT
```

#### Monitor the progress of an effector
     
To monitor progress on an application as it deploys, for example, one could use a shell loop:

```bash
$ while br application Tomcat entity tomcatServer activity | grep 'In progress' ; do 
  sleep 1; echo ; date; 
done
```

This loop will exit when the application has deployed successfully or has failed.  If it fails then the 'stderr' 
command may provide information about what happened in any activities that have associated streams:

```bash
$ br application Tomcat entity tomcatServer act KLTxDkoa stderr
```

#### Diagnose a failure

If an activity has failed, the "DetailedStatus" value will help us diagnose what went wrong by showing information about the failure.

```
$ br application evHUlq0n entity tomcatServer activity lZZ9x662
Id:                  lZZ9x662   
DisplayName:         post-start   
Description:            
EntityId:            qZeyoITy   
EntityDisplayName:   tomcatServer   
Submitted:           Mon Jan 25 12:54:55 GMT 2016   
Started:             Mon Jan 25 12:54:55 GMT 2016   
Ended:               Mon Jan 25 12:59:56 GMT 2016   
CurrentStatus:       Failed   
IsError:             true   
IsCancelled:         false   
SubmittedByTask:     hWU7Qvgm   
Streams:                
DetailedStatus:      "Failed after 5m: Software process entity TomcatServerImpl{id=qZeyoITy} did not pass is-running check within the required 5m limit (5m elapsed)

java.lang.IllegalStateException: Software process entity TomcatServerImpl{id=qZeyoITy} did not pass is-running check within the required 5m limit (5m elapsed)
	at org.apache.brooklyn.entity.software.base.SoftwareProcessImpl.waitForEntityStart(SoftwareProcessImpl.java:586)
	at org.apache.brooklyn.entity.software.base.SoftwareProcessImpl.postDriverStart(SoftwareProcessImpl.java:260)
	at org.apache.brooklyn.entity.software.base.SoftwareProcessDriverLifecycleEffectorTasks.postStartCustom(SoftwareProcessDriverLifecycleEffectorTasks.java:169)
	at org.apache.brooklyn.entity.software.base.lifecycle.MachineLifecycleEffectorTasks$PostStartTask.run(MachineLifecycleEffectorTasks.java:570)
	at java.util.concurrent.Executors$RunnableAdapter.call(Executors.java:511)
	at org.apache.brooklyn.util.core.task.DynamicSequentialTask$DstJob.call(DynamicSequentialTask.java:342)
	at org.apache.brooklyn.util.core.task.BasicExecutionManager$SubmissionCallable.call(BasicExecutionManager.java:468)
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
	at java.lang.Thread.run(Thread.java:745)"
```

Adding the "--children" or "-c" parameter will show the activity's child activities, to allow the hierarchical structure 
of the activities to be investigated:

```
$ br application Tomcat entity tomcatServer activity -c jwwcJWmF
Id         Task                         Submitted                      Status   
UpYRc3fw   copy-pre-install-resources   Thu Dec 17 15:04:43 GMT 2015   Completed   
ig8sBHQr   pre-install                  Thu Dec 17 15:04:43 GMT 2015   Completed   
Elp4HaVj   pre-install-command          Thu Dec 17 15:04:43 GMT 2015   Completed   
YOvNobJk   setup                        Thu Dec 17 15:04:43 GMT 2015   Completed   
VN3cDKki   copy-install-resources       Thu Dec 17 15:08:43 GMT 2015   Completed   
xDJXQC0J   install                      Thu Dec 17 15:08:43 GMT 2015   Completed   
zxMDXUxz   post-install-command         Thu Dec 17 15:08:58 GMT 2015   Completed   
qnQnw7Oc   customize                    Thu Dec 17 15:08:58 GMT 2015   Completed   
ug044ArS   copy-runtime-resources       Thu Dec 17 15:08:58 GMT 2015   Completed   
STavcRc8   pre-launch-command           Thu Dec 17 15:08:58 GMT 2015   Completed   
HKrYfH6h   launch                       Thu Dec 17 15:08:58 GMT 2015   Completed   
T1m8VXbq   post-launch-command          Thu Dec 17 15:08:59 GMT 2015   Completed   
n8eK5USE   post-launch                  Thu Dec 17 15:08:59 GMT 2015   Completed   
```

## Scopes in CLI commands
Many commands require a "scope" expression to indicate the target on which they operate. The scope expressions are
as follows (values in brackets are aliases for the scope):

- ```application``` APP-ID   (app, a)  
 Selects an application, e.g. "br application myapp"  
- ```entity```      ENT-ID   (ent, e)  
 Selects an entity within an application scope, e.g. ```br application myapp entity myserver```  
- ```effector```    EFF-ID   (eff, f)  
 Selects an effector of an entity or application, e.g. ```br a myapp e myserver eff xyz```  
- ```config```      CONF-KEY (conf, con, c)  
 Selects a configuration key of an entity e.g. ```br a myapp e myserver config jmx.agent.mode```  
- ```activity```    ACT-ID   (act, v)  
 Selects an activity of an entity e.g. ```br a myapp e myserver act iHG7sq1```  

For example
```bash
$ br application Tomcat entity tomcatServer config
```
runs the ```config``` command with application scope of ```Tomcat``` and entity scope of ```tomcatServer```.

{% if output.name == 'website' %}
## Next

We will look next at a slightly more complex example, which will illustrate the capabilities of Brooklyn's
**[policies](policies.md)** mechanism, and how to configure dependencies between application entities.
{% endif %}
