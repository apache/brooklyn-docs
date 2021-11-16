---
title: High Availability
layout: website-normal
children:
- high-availability-supplemental.md
---

Brooklyn will automatically run in HA mode if multiple Brooklyn instances are started
pointing at the same persistence store.  One Brooklyn node (e.g. the first one started)
is elected as HA master:  all *write operations* against Brooklyn entities, such as creating
an application or invoking an effector, should be directed to the master.

Once one node is running as `MASTER`, other nodes start in either `STANDBY` or `HOT_STANDBY` mode:

* In `STANDBY` mode, a Brooklyn instance will monitor the master and will be a candidate
  to become `MASTER` should the master fail. Standby nodes do *not* attempt to rebind
  until they are elected master, so the state of existing entities is not available at
  the standby node.  However a standby server consumes very little resource until it is
  promoted.
  
* In `HOT_STANDBY` mode, a Brooklyn instance will read and make available the live state of
  entities.  Thus a hot-standby node is available as a read-only copy.
  As with the standby node, if a hot-standby node detects that the master fails,
  it will be a candidate for promotion to master.

* In `HOT_BACKUP` mode, a Brooklyn instance will read and make available the live state of
  entities, as a read-only copy. However this node is not able to become master,
  so it can safely be used to test compatibility across different versions.

To explicitly specify what HA mode a node should be in, the following options are available
for the config option `highAvailabilityMode` in [`org.apache.brooklyn.osgilauncher.cfg`](/guide/ops/paths.md):

* `DISABLED`: management node works in isolation; it will not cooperate with any other standby/master nodes in management plane
* `AUTO`: will look for other management nodes, and will allocate itself as standby or master based on other nodes' states
* `MASTER`: will startup as master; if there is already a master then fails immediately
* `STANDBY`: will start up as lukewarm standby; if there is not already a master then fails immediately
* `HOT_STANDBY`: will start up as hot standby; if there is not already a master then fails immediately
* `HOT_BACKUP`: will start up as hot backup; this can be done even if there is not already a master; this node will not be a master 

The REST API offers live detection and control of the HA mode,
including setting priority to control which nodes will be promoted on master failure:

* `/server/ha/state`: Returns the HA state of a management node (GET),
  or changes the state (POST)
* `/server/ha/states`: Returns the HA states and detail for all nodes in a management plane
* `/server/ha/priority`: Returns the HA node priority for MASTER failover (GET),
  or sets that priority (POST)
  
The High Availability management plane can also be controlled via the Brooklyn UI. More information is available in [`Configuraing HA - an example`](/guide/ops/high-availability/high-availability-supplemental.md)

Note that when making a POST request to a non-master server it is necessary to pass a `Brooklyn-Allow-Non-Master-Access: true` header.
For example, the following cURL command could be used to change the state of a `STANDBY` node on `localhost:8082` to `HOT_STANDBY`:

    curl -v -X POST -d mode=HOT_STANDBY -H "Brooklyn-Allow-Non-Master-Access: true" http://localhost:8082/v1/server/ha/state

When running a single server, you can disable HA mode. You can recover from a failure
by restarting the process or launching a replacement machine, pointing at the same 
persisted state. A single server running in HA mode will have the following differences
in behaviour:

* If you run Brooklyn and then kill it (e.g. `kill -9` or turn off the
  VM), when you start Brooklyn again it will wait to confirm the previous
  server is really dead. It waits for 30 seconds after the old server's last
  heartbeat, by default.
* The HA status shows all previous runs of the Brooklyn server (it gets
  a new node-id each time it restarts). This list will get longer and
  longer if you keep restarting Brooklyn, while pointing at the same persisted
  state, until you clear out terminated instances from the list (via the
  UI or the REST API).
* The logging at startup can be quite different (e.g. in HA mode, "Brooklyn
  initialisation (part two) complete" can mean that the server has finished
  becoming the 'standby'. Care should be taken if searching or parsing the logs.

