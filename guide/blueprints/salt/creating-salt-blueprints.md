---
title: Creating Blueprints with Salt
title_in_menu: Creating Blueprints with Salt
layout: website-normal
---

To write a blueprint to use Salt with Brooklyn it will help to have a degree of familiarity with Salt itself. In the 
sections below, when the Brooklyn configuration is described, the underlying Salt operation is also noted briefly, for 
clarity for readers who know Salt.

To manage a node with Salt, create a blueprint containing a service of type `org.apache.brooklyn.entity.cm.salt.SaltEntity`
and define the `formulas` and `start_states` 
For example:

    name: Salt Example setting up Apache httpd
    location: my-cloud
    services:
    - id: httpd-from-salt
      type: org.apache.brooklyn.entity.cm.salt.SaltEntity
      formulas:
      - https://github.com/saltstack-formulas/apache-formula/archive/master.tar.gz
      start_states:
      - apache
    
This example specifies that Brooklyn should use Salt to download the `apache-formula` from the Saltstack repository on
Github. The apache formula contains the Apache web server with a simple "it worked" style index page. To start the 
entity, Brooklyn will use Salt to apply the `apache` state, which will bring up the web server.

A typical usage of the Salt entity might be to include a formula from the Saltstack repository, such as `apache` above,
and another formula created by the blueprint author, with additional states, such as web site content for the apache 
server.

### Start States

The `start_states` configuration key defines the top level list of states that will be applied using Salt.  These values
are added to the Salt `top.sls` file and applied using `state.apply`.  This configuration key is mandatory.

### Stop States

The `stop_states` configuration key is used to specify states that should be applied when the 'stop' effector
is invoked on the entity.  For example, the Saltstack `mysql` [formula](https://github.com/saltstack-formulas/mysql-formula)
supplies a state `mysql.disabled` that will shut down the database server.

If the Saltstack formula does not supply a suitable stop state, the blueprint author can create a suitable state and
include it in an additional formula to be supplied in the `formulas` section. 

The `stop_states` configuration key is optional; 
if it is not provided, Brooklyn assumes that each state `S` in the `start_states` will have a matching `S.stop` state.  
If any `S` does not have such a state, the stop effector will fail stopping processes.
Note that on a machine created for this entity, Brooklyn's default behaviour may be to proceed to destroy the VM,
so stop states are not always needed unless there is a cleaner shutdown process or you are using long-running servers.


### Restart States

For completeness, Brooklyn also provides a `restart_states` configuration key. These states are applied by the restart
effector, and blueprint authors may choose to provide custom states to implement restart if that is applicable for their
application. 

This key is again optional.
If not supplied, Brooklyn will go through each of the states `S` in `start_states` 
looking for a matching `S.restart` state defined in the formulas.
If all exist, these will be applied by the restart effector. 
If none exist, Brooklyn will invoke the `stop` and then `start` effectors -- 
so `restart` states are not required for Brooklyn to use Salt.
(If some but not all have matching `restart` states, 
Brooklyn will fail the restart, on the assumption that the configuration is incomplete.)   

### Formulas

The `formulas` key provides the URLs for archives containing the Salt formulas that defined the required states. These
archives are downloaded to the `/srv/formula` directory on the minion and added to the state filesystem roots 
configuration in Salt's minion config, so that their states are available for a `state.apply`.

### Pillar Configuration

A typical Salt deployment will include both states (provided via Salt formulas) and configuration data, provided through 
Salt's "Pillar" component.  Brooklyn provides configuration keys for the Salt entity to specify where to get the Pillar
configuration data.  For example:

    name: Salt Example setting up MySQL with a Pillar
    location: my-cloud
    services:
    - id: mysql-from-salt-with-my-pillar
      type: org.apache.brooklyn.entity.cm.salt.SaltEntity
    
      formulas:
      - https://github.com/saltstack-formulas/mysql-formula/archive/master.tar.gz
      - http://myhost:8080/my-mysql-formula.tar.gz
    
      start_states:
      - mysql
      stop_states: 
      - mysql.disabled
    
      pillars: 
      - mysql
      pillarUrls:
      - http://myhost:8080/my-mysql-pillar.tar.gz


This blueprint contains the MySQL database, and includes a formula available from `myhost` which includes the schema
information for the DB. The MySQL formula from Saltstack has extensive configurability through Salt Pillars. In the 
blueprint above, Brooklyn is instructed to apply the pillars defined in the `pillars` configuration key.  (This will 
add these values to the Salt Pillars `top.sls` file.)  The pillar data must be downloaded; for this, the `pillarUrls` key
provides the address of an archive containing the Pillar data.  The contents of the archive will be extracted and put
in the `/srv/pillar` directory on the minion, in order to be available to Salt when applying the pillar. For example,
the archive above can simply have the structure

    pillar/
    |
    +- mysql/
       |
       +- init.sls

The init.sls contains the pillar configuration values, such as 

    # Manage databases
    database:
      - orders
    schema:
      orders:
        load: True
        source: salt://mysql/files/orders.schema

Meanwhile the `my-mysql-formula.tar.gz` formula archive contains the schema:

    my-mysql-formula/
    |
    +- mysql/
       |
       +- files/
          |
          +- orders.schema

Note that the blueprint above defines an `id` for the Salt entity.  This id, if provided, is set as the minion id in
the Salt configuration file.  This is useful particularly for Pillar configuration, as, if there are more than one 
Salt managed nodes in the application, they can share a common Pillar file, with appropriate subdivisions of pillar 
data based on minion id.

### Highstate Sensors

The Salt entity exposes the Salt "highstate" on the node via Brooklyn sensors.  Firstly a single sensor `salt.states` 
contains a list of all the top level Salt state ID declarations in the highstate.  For example, for the mysql case 
above, this might look like:

    ["mysql_additional_config", "mysql_config", "mysql_db_0", "mysql_db_0_load", "mysql_db_0_schema", "mysql_debconf",
     "mysql_debconf_utils", "mysql_python", "mysql_user_frank_localhost", "mysql_user_frank_localhost_0", 
     "mysql_user_nopassuser_localhost", "mysqld"]

Then, for each ID and each Salt state function in that ID, a Brooklyn sensor is created, containing a map of the data
from the highstate.  For example, the `salt.state.mysqld.service.running` sensor would have a value like:

    {"name":"mysql", "enable":true, "watch":[{"pkg":"mysqld"}, {"file":"mysql_config"}], "order":10005}


### saltCall Effector

The Salt entity includes a general purpose Salt effector, `saltCall`, which permits execution of Salt commands via
`salt-call --local`.  It contains a single parameter, `spec`, which specifies the command to invoke.  For example, 
invoking the effector with a `spec` value of `network.interfaces --out=yaml` would return a YAML formatted map of the 
network interfaces on the minion.

