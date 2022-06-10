---
title: CLI Reference Guide
layout: website-normal
menu_parent: index.md
children:
- { section: Usage }
- { section: List of Commands }
- { section: Scopes }
- { section: Abbreviations }
- { section: Command Reference }
---

## Usage
{% highlight text %}
NAME:
   br - A Brooklyn command line client application

USAGE:
   br [global options] command [command options] [arguments...]
{% endhighlight %}

## List of Commands
Commands whose description begins with a `*` character are particularly experimental
and likely to change in upcoming releases.  

{% highlight text %}
COMMANDS:

   Commands whose description begins with a "*" character are particularly experimental and likely to change in upcoming
   releases.  If not otherwise specified, "SCOPE" below means application or entity scope.  If an entity scope is not
   specified, the application entity is used as a default.

   access		Show access control
   activity		Show the activity for an application / entity
   add-catalog		(deprecated, use catalog add) Add a new catalog item from the supplied YAML (a file or HTTP URL)
   add-children		* Add a child or children to this entity from the supplied YAML
   application		Show the status and location of running applications
   catalog		Catalog operations
   config		Show the config for an application or entity
   delete		* Delete (expunge) a brooklyn application
   deploy		Deploy a new application from the given YAML (read from file or URL, or stdin)
   destroy-policy	Destroy a policy
   effector		Show the effectors for an application or entity
   entity		Show the entities of an application or entity
   env			Show the ENV stream for a given activity
   invoke		Invoke an effector of an application and entity
   locations		* List the available locations
   login		Login to brooklyn
   policy		Show the policies for an application or entity
   rename		Rename an application or entity
   restart		Invoke restart effector on an application and entity
   sensor		Show values of all sensors or named sensor for an application or entity
   set			Set config for an entity
   spec			Get the YAML spec used to create the entity, if available
   start		Invoke start effector on an application and entity
   start-policy		Start or resume a policy
   stderr		Show the STDERR stream for a given activity
   stdin		Show the STDIN stream for a given activity
   stdout		Show the STDOUT stream for a given activity
   stop			Invoke stop effector on an application and entity
   stop-policy		Suspends a policy
   tree			* Show the tree of all applications
   version		Display the version of the connected Brooklyn
   help			
   
GLOBAL OPTIONS:
   --skipSslChecks	Skip verification of server's certificate chain and hostname (for use with self-signed certs)
   --help, -h		show help
   --version, -v	print the version
{% endhighlight %}


## Scopes
Many commands require a "scope" expression to indicate the target on which they operate.
Where this
is required the usage statements below will use the shorthand nomenclature of `<X-scope>`.  
The various scopes should be replaced on the command line as:

- `<app-scope>`  
  `application <Name|AppID>`

- `<entity-scope>`  
  `application <Name|AppID> entity <Name|EntityID>`

- `<effector-scope>`  
  `application <Name|AppID> effector <Name>`  
  `application <Name|AppID> entity <Name|EntityID> effector <Name>`

- `<config-scope>`  
  `application <Name|AppID> entity <Name|EntityID> config <ConfigID>`

- `<activity-scope>`  
  `activity <ActivityID>`  
  `application <Name|AppID> entity <Name|EntityID> activity <ActivityID>`

## Abbreviations
Many of the commands and scopes have shortened aliases:

{% highlight text %}
activity     act
application  app
entity       ent
policy       pol
{% endhighlight %}

## Command Reference

### Login

- `br login <URL> [username [password]]`  
  Login to Brooklyn using basic authorization (implicit --authorization=Basic).  The CLI will prompt for a password if 
  it is not provided.  If the Brooklyn server is running on localhost with no security enabled, the username and 
  password may be omitted.  
  On successful login, the version of the connected Brooklyn server is shown.

- `br login <URL> --authorization=Bearer:<JWT-token>`  
  Login to Brooklyn using oauth. The CLI will try to use the provided token for login in the Brooklyn server.
  On successful login, the version of the connected Brooklyn server is shown. If not, it will show the server error 
  response
  
- `br version`
  Show the version of the connected Brooklyn server.

### Applications

- `br deploy ( <FILE|URL> | - )`  
  Deploy an application based on the supplied YAML file or URL, or read from STDIN when `-` is given instead of a file name.

- `br application`  
  List the running applications.

- `br application <Name|AppID>`  
  Show the detail for an application.

- `br <app-scope> config`  
  Show the configuration details for an application.

- `br <app-scope> config <ConfigID>`  
  Show the value for a configuration item.

- `br <app-scope> spec`  
  Show the YAML specification used to create the application.

- `br <app-scope> rename <Name>`  
  Rename the application to <Name>.

- `br <app-scope> stop`  
  Stop an application.  See below for further information on the `stop` effector.

- `br <app-scope> start`  
  Start an application.  See below for further information on the `start` effector.

- `br <app-scope> restart`  
  Restart an application.  See below for further information on the `restart` effector.

- `br <app-scope> delete`  
  Delete an application from Brooklyn.  
  **NOTE:** Use this command with care.  Even if the application / entities are still running, Brooklyn will drop all 
  knowledge of them and they will be left running in an 'orphaned' state.

### Entities

- `br <app-scope> entity`    
  List the child entities for an application.

- `br <entity-scope> entity`  
  List the child entities for an entity.

- `br <app-scope> entity <Name|EntityID>`  
  Show the detail of an entity.

- `br <app-scope> entity -c <Name|EntityID>`  
  List the child entities for an entity.

- `br <entity-scope> config`  
  Show the configuration details for an entity.

- `br <entity-scope> config <ConfigID>`  
  Show the value for a configuration item.

- `br <config-scope> set <ConfigValue>`  
  Set the value of a configuration item.  

- `br <entity-scope> spec`  
  Show the YAML specification used to create the entity.

- `br <entity-scope> rename <Name>`  
  Rename the entity to <Name>.

- `br <entity-scope> stop`  
  Stop an entity.  See below for further information on the `stop` effector.

- `br <entity-scope> start`  
  Start an entity.  See below for further information on the `start` effector.

- `br <entity-scope> restart`  
  Restart an entity.  See below for further information on the `restart` effector.

### Sensors

- `br <app-scope> sensor`  
  List the sensors and values for an application.

- `br <app-scope> sensor <SensorID>`  
  Show the value for a sensor.

- `br <entity-scope> sensor`  
  List the sensors and values for an entity.

- `br <entity-scope> sensor <SensorID>`  
  Show the value for a sensor.

### Effectors

- `br <app-scope> effector`  
  List the effectors for an application.

- `br <app-scope> effector <EffectorID>`  
  Show the detail for an application effector.

- `br <app-scope> effector <EffectorID> invoke`  
  Invoke the effector without any parameters.

- `br <app-scope> effector <EffectorID> invoke [-P <param>=<value> ...]`
  Invoke the effector with one of more parameters.

- `br <entity-scope> effector`  
  List the effectors for an entity.

- `br <entity-scope> effector <EffectorID>`  
  Show the detail for an entity effector.

- `br <entity-scope> effector <EffectorID> invoke`  
  Invoke the effector without any parameters.

- `br <entity-scope> effector <EffectorID> invoke [-P <param>=<value> ...]`
  Invoke the effector with one of more parameters.  
  If the parameter value is
  complex or multi-lined it may be provided in a file and referenced as:  
  `<param>=@<FILE>`

**NOTE** Shortcut commands have been provided for the standard start, restart and stop effectors.  For example:  

- `br <app-scope> stop`  
- `br <entity-scope> restart restartChildren=true`  

### Policies

- `br <entity-scope> policy`  
  List the policies for an entity.

- `br <entity-scope> policy <PolicyID>`  
  Show the detail for an entity policy.

- `br <entity-scope> start-policy <PolicyID>`  
  Start an entity policy.

- `br <entity-scope> stop-policy <PolicyID>`  
  Stop an entity policy.

- `br <entity-scope> destroy-policy <PolicyID>`  
  Destroy an entity policy.

### Activities

- `br <app-scope> activity`  
  List the activities for an application.

- `br <entity-scope> activity`  
  List the activities for an entity.

- `br <activity-scope> activity`  
  List the activities for an activity (ie its children).

- `br activity <ActivityID>`  
  Show the detail for an activity.

- `br activity -c <ActivityID>`  
  List the child activities of an activity.

- `br <activity-scope> stdin`  
  Show the `<STDIN>` stream for an activity.

- `br <activity-scope> stdout`  
  Show the `<STDOUT>` stream for an activity.

- `br <activity-scope> stderr`  
  Show the `<STDERR>` stream for an activity.

- `br <activity-scope> env`  
  Show the Environment for an activity.

### Miscellaneous


#### Applications

- `br tree`  
  List all of the applications and entities in a tree representation.

#### Entities

- `br <entity-scope> add-children <FILE|URL>`  
  Add a child or children to the entity from local YAML file or a URL.

#### Catalog

- `br catalog list <TYPE>`  
  List the application catalog, where `TYPE` is one of "application", "entity", "location", or "policy"
  
- `br catalog delete  <TYPE> <ITEM_ID:VERSION>`  
  Delete an item from the catalog, where `TYPE` is as above, and supplying the item's id and version 
  
- `br catalog add <FILE|URL>`  
  Add catalog entries from a local YAML file or a URL. The id and version of added entries are displayed.

- `br locations`  
  List the location catalog. (Includes all locations including those defined in `brooklyn.cfg`)

- `br access`  
  Show if you have access to provision locations.
