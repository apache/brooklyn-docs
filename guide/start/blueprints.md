---
title: Deploying Blueprints
layout: website-normal
---
# {{ page.title }}

Blueprints are descriptors or patterns which describe how Apache Brooklyn should deploy applications. Blueprints are written in [YAML](https://en.wikipedia.org/wiki/YAML) and many of the entities available are defined in the __[Brooklyn Catalog]({{ book.path.website }}/learnmore/catalog/)__.

## Launching from a Blueprint

We'll start by deploying an application with a simple YAML blueprint containing an [Apache Tomcat](https://tomcat.apache.org/) server.

Copy the blueprint below into a text file, "myapp.yaml", in your workspace (Note, to copy the file you can
hover your mouse over the right side of the text box below to get a Javascript "copy" button).

```yaml
name: Tomcat
services:
- type: org.apache.brooklyn.entity.webapp.tomcat.TomcatServer
  name: tomcatServer
location: <your-location-definition-goes-here>
```


## Locations

Before you can create an application with this configuration, you need to modify the YAML to specify a location. Locations in Apache Brooklyn are server resources which Brooklyn can use to deploy applications. These locations may be servers or cloud providers which provide access to servers. 

In order to configure the location in which Apache Brooklyn launches an application, replace the ```location:``` element with values for your chosen target environment. Here are some examples of the various location types:

{% method -%}

{% common -%}
{% if output.name == 'website' %}
**Hint:** in the top right of this page are buttons to select a location. Choose your location to see the most appropriate instructions here.
{% endif %}

{% sample lang="vagrant" -%}
The Vagrant configuration described in [Running Apache Brooklyn](running.md), on the previous page is the recommended way of running this tutorial. This configuration comes with four blank vagrant configurations called byon1 to byon4.

These can be launched by entering the following command into the terminal in the vagrant configuration directory.

```bash
 $ vagrant up byon1 byon2 byon3 byon4
```

The location in "myapp.yaml" can now be replaced with the following YAML to launch using these vagrant servers.

```yaml
location:
  byon:
    user: vagrant
    password: vagrant
    hosts:
      - 10.10.10.101
      - 10.10.10.102
      - 10.10.10.103
      - 10.10.10.104
```

{% sample lang="clouds" -%}
Apache Brooklyn uses [Apcahe jclouds](http://jclouds.apache.org/) to support a range of cloud locations. More information on the range of providers and configurations is available [here]({{ book.path.guide }}/locations/#clouds).

As an example, here is a configuration for [Amazon Web Services (AWS)](http://www.aws.amazon.com). Swap the identity and credential with your AWS account details, then replace the location in your "myapp.yaml" with this.

```yaml
location:
  jclouds:aws-ec2:
    identity: ABCDEFGHIJKLMNOPQRST
    credential: s3cr3tsq1rr3ls3cr3tsq1rr3ls3cr3tsq1rr3l
```

{% sample lang="byon" -%}
The Bring Your Own Nodes (BYON) configuration allows Apache Brooklyn to make use of already available servers. These can be specified by a list of IP addresses with a user and password as shown below. More information including the full range of configuration options is available [here]({{ book.path.guide }}/locations/#byon). 

Replace the hosts, user and password in the example below with your own server details, then replace the location in your "myapp.yaml" with this.

```yaml
location:
  byon:
    user: myuser
    password: mypassword
    # or...
    #privateKeyFile: ~/.ssh/my.pem
    hosts:
    - 192.168.0.18
    - 192.168.0.19
```

{% endmethod %}

**Note**: For instructions on setting up a variety of locations or storing credentials/locations in a file on disk rather than in the blueprint, see __[Locations]({{ book.path.guide }}/locations)__ in the Operations section of the User Guide.

## Deploying the Application

First, log in to brooklyn with the command line interface (CLI) tool by typing:
```
$ br login http://localhost:8081/
```

To secure the Apache Brooklyn instance, you can add a username and password to Brooklyn's properties file, as described in the User Guide [here](../ops/configuration/brooklyn_cfg.md). 
If this is configured, the login command will require an additional parameter for the userid and will then prompt for a password.

Now you can create the application with the command below:

```
$ br deploy myapp.yaml 
Id:       hTPAF19s   
Name:     Tomcat   
Status:   In progress  
```

Depending on your choice of location it may take some time for the application to start, the next page describes how 
you can monitor the progress of the application deployment and verify if it was successful.

{% if output.name == 'website' %}
## Next
Having deployed an application, the next step is **[monitoring and managing](managing.md)** it.
{% endif %}
