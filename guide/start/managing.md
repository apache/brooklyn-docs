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

{% read _br.applications.camp.md %}

## Entities

{% read _br.entities.camp.md %}

## Sensors

{% read _br.sensors.camp.md %}

## Effectors

{% read _br.effectors.camp.md %}

## Activities

{% read _br.activities.camp.md %}

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
