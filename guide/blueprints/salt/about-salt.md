---
title: About Salt
title_in_menu: About Salt
layout: website-normal
---

## What you need to know about Salt

Salt is designed to work in either what it calls a 'master/minion' or a 'masterless' topology.
 
In the former, the master server acts as a managing controller for any number of client nodes, called 'minions'. 
A salt daemon running on the minion connects back to the master server for its operation, and manages the software on 
the minion according to a specification of 'states' defined in Salt configuration files.  In the latter, there is no 
master, and the salt daemon on the minion operates based on the Salt files on the minion node.  This is the mode 
currently supported by Brooklyn.

A 'State' in Salt is a specification of a configuration of some aspect of a system, such as what packages are installed,
what system services are running, what files exist, etc.  Such states are described in "SLS" files (for SaLt State 
file). These files are typically written as templates using the "Jinja" templating engine.  The actual SLS files for the
minion are then created by processing the templates using configuration data provided via Salt's "Pillar" system.

Salt comes with built-in support for many software systems, and has a repository of pre-written Salt states known as 
'formulas' on GitHub, at [https://github.com/saltstack-formulas](https://github.com/saltstack-formulas).

### How Brooklyn interacts with Salt

Brooklyn provides a Salt entity type. An entity of this type can be specified in a blueprint in order to provision the 
node through Salt. The Salt entity will download Salt and install it on the node. The entity type supports the 
configuration of Salt formulas and Pillar data to download, and the configuration of what Salt states to apply. 
These are managed using Salt in 'masterless' mode, as described on the
[Saltstack site](https://docs.saltstack.com/en/latest/topics/tutorials/quickstart.html#salt-masterless-quickstart),
using the 'salt-call' functionality of Salt.

The Salt 'highstate' (the collection of states applied to the system) is exposed as a sensor on the entity.  An effector
 is provided on the entity that supports general purpose Salt instructions.



