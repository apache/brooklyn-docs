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



So far we have gone through Apache Brooklyn's ability to *deploy* an application blueprint to a location, but this is just 
the beginning. Next we will outline how to *manage* the application that has been deployed.

## Applications

{% read _br_applications.camp.md %}

## Entities

{% read _br_entities.camp.md %}

## Sensors

{% read _br_sensors.camp.md %}

## Effectors

{% read _br_effectors.camp.md %}

## Activities

*Activities* are the actions an application or entity takes within Apache Brooklyn. The ```activity``` command allows us to list out these activities. 

To view a list of all activities associated with an entity enter:

{% highlight bash %}
$ br application Tomcat entity tomcatServer activity
{% endhighlight %}
<pre>
Id         Task                                       Submitted                      Status      Streams   
LtD5P1cb   start                                      Thu Dec 17 15:04:43 GMT 2015   Completed   
l2qo4vTl   provisioning (FixedListMachineProvisi...   Thu Dec 17 15:04:43 GMT 2015   Completed   
wLD764HE   pre-start                                  Thu Dec 17 15:04:43 GMT 2015   Completed    
KLTxDkoa   ssh: initializing on-box base dir ./b...   Thu Dec 17 15:04:43 GMT 2015   Completed   env,stderr,stdin,stdout   
jwwcJWmF   start (processes)                          Thu Dec 17 15:04:43 GMT 2015   Completed        
...
</pre>

To view the details of an individual activity, add its ID to the command. In our case this is `jwwcJWmF`

{% highlight bash %}
$ br application Tomcat entity tomcatServer activity jwwcJWmF
{% endhighlight %}
<pre>
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
</pre>


#### Things we might want to do

<div class="panel-group" id="accordionB">
        <div class="panel panel-default">
            <a data-toggle="collapse" data-parent="#accordionB" href="#collapseOneB"><div class="panel-heading">
                <h4 class="panel-title">
                    View Input and Output Streams
                </h4>
            </div></a>
            <div id="collapseOneB" class="panel-collapse collapse in">
                <div class="panel-body">
<p>
If an activity has associated input and output streams, these may be viewed by providing the activity scope and
using the commands, "env", "stdin", "stdout", and "stderr".  For example, for the "initializing on-box base dir"
activity from the result of the earlier example,
</p>
{% highlight bash %}
$ br application Tomcat entity tomcatServer act KLTxDkoa stdout
{% endhighlight %} 
<pre>
BASE_DIR_RESULT:/home/vagrant/brooklyn-managed-processes:BASE_DIR_RESULT
</pre>
                </div>
            </div>
        </div>
        <div class="panel panel-default">
            <a data-toggle="collapse" data-parent="#accordionB" href="#collapseTwoB"><div class="panel-heading">
                <h4 class="panel-title">
                    Monitor the progress of an effector
                </h4>
            </div></a>
            <div id="collapseTwoB" class="panel-collapse collapse">
                <div class="panel-body">
                        
<p>       
To monitor progress on an application as it deploys, for example, one could use a shell loop:
</p>
{% highlight bash %}
$ while br application Tomcat entity tomcatServer activity | grep 'In progress' ; do 
  sleep 1; echo ; date; 
done
{% endhighlight %}
<p>
This loop will exit when the application has deployed successfully or has failed.  If it fails then the 'stderr' 
command may provide information about what happened in any activities that have associated streams:
</p>
{% highlight bash %}
$ br application Tomcat entity tomcatServer act KLTxDkoa stderr
{% endhighlight %}                      
                
                </div>
            </div>
        </div>
        <div class="panel panel-default">
            <a data-toggle="collapse" data-parent="#accordionB" href="#collapseThreeB"><div class="panel-heading">
                <h4 class="panel-title">
                    Diagnose a failure
                </h4>
            </div></a>
            <div id="collapseThreeB" class="panel-collapse collapse">
                <div class="panel-body">
                
<p>
If an activity has failed, the "DetailedStatus" value will help us diagnose what went wrong by showing information about the failure.
</p>
{% highlight bash %}
$ br application evHUlq0n entity tomcatServer activity lZZ9x662
{% endhighlight %}
<pre>
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
</pre>
<p>
Adding the "--children" or "-c" parameter will show the activity's child activities, to allow the hierarchical structure 
of the activities to be investigated:
</p>
{% highlight bash %}
$ br application Tomcat entity tomcatServer activity -c jwwcJWmF
{% endhighlight %}
<pre>
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
</pre>                
                      
                </div>
            </div>
        </div>
    </div>


{::comment}
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
{% highlight bash %}
$ br application Tomcat entity tomcatServer config
{% endhighlight %}
runs the ```config``` command with application scope of ```Tomcat``` and entity scope of ```tomcatServer```.

{:/comment}

## Next

We will look next at a slightly more complex example, which will illustrate the capabilities of Brooklyn's
**[policies](policies.md)** mechanism, and how to configure dependencies between application entities.
