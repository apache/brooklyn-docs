---
title: Configuring HA - an example
layout: website-normal
---

This supplements the [High Availability](/guide/ops/high-availability) documentation
and provides an example of how to configure a pair of Apache Brooklyn servers to run in master-standby mode with a shared NFS datastore

### Prerequisites
- Two VMs (or physical machines) have been provisioned
- NFS or another suitable file system has been configured and is available to both VMs*
- An NFS folder has been mounted on both VMs at `/mnt/brooklyn-persistence` and both machines can write to the folder

\* Brooklyn can be configured to use either an object store such as S3, or a shared NFS mount. The recommended option is to use an object
store as described in the [Object Store Persistence](/guide/ops/persistence#object-store-persistence) documentation. For simplicity, a shared NFS folder
is assumed in this example

### Launching
To start, download and install the latest Apache Brooklyn release on both VMs following the instructions in
[Running Apache Brooklyn](/guide/start/running.md)

On the first VM, which will be the master node, set the following configuration options in [`org.apache.brooklyn.osgilauncher.cfg`](/guide/ops/paths.md):

- highAvailabilityMode: MASTER
- persistMode: AUTO
- persistenceDir: /mnt/brooklyn-persistence

Then launch Brooklyn with:

{% highlight bash %}
$ bin/start
{% endhighlight %}

If you are using RPMs/deb to install, please see the [Running Apache Brooklyn](/guide/start/running.md) 
documentation for the appropriate launch commands

Once Brooklyn has launched, on the second VM, set the following configuration options in [`org.apache.brooklyn.osgilauncher.cfg`](../paths.html):

- highAvailabilityMode: AUTO
- persistMode: AUTO
- persistenceDir: /mnt/brooklyn-persistence

Then launch the standby Brooklyn with:

{% highlight bash %}
$ bin/start
{% endhighlight %}

### Failover
When running as a HA standby node, each standby Brooklyn server (in this case there is only one standby) will check the shared persisted state
every one second to determine the state of the HA master. If no heartbeat has been recorded for 30 seconds, then an election will be performed
and one of the standby nodes will be promoted to master. At this point all requests should be directed to the new master node.
If the master is terminated gracefully, the secondary will be immediately promoted to mater. Otherwise, the secondary will be promoted after 
heartbeats are missed for a given length of time. This defaults to 30 seconds, and is configured in `brooklyn.cfg` using 
`brooklyn.ha.heartbeatTimeout`

In the event that tasks - such as the provisioning of a new entity - are running when a failover occurs, the new master will display the current
state of the entity, but will not resume its provisioning or re-run any partially completed tasks. In this case it may be necessary
to remove the entity and reprovision it. In the case of a failover whilst executing a task called by an effector, it may be possible to simple
call the effector again

### High Availability Management

On top of the [`API`](/guide/ops/high-availability/index.md), High Availability can be explicitly controlled from the Brooklyn UI, 
which allows for the server to change its priority and request to promote itself to master. 

This can be achieved via the `HA Status` table in the `About` page, which displays information about
nodes in the current management plane. The control menu is opened by selecting the `Manage` option on the current server entry in the table. 
The following menu allows to change the priority value, as well as the status of the node.

- If a node is `MASTER`, it can demote itself by changing to another state. In such case, a new master is selected from available standby servers, 
basing on their priority.
- If a node is `STANDBY`, or `HOT_STANDBY`, it can promote itself by changing to `MASTER` state. 
It is recommended for this server to have the highest priority amongst all available servers.
  
Additionally, terminated servers can be removed from the persistence with `Remove` option (visible upon hover over the terminated node in the `HA Status` Table). 
All terminated servers can be removed at once with `Remove terminated nodes` option. These operations are only available to the master node.

### Client Configuration
It is the responsibility of the client to connect to the master Brooklyn server. This can be accomplished in a variety of ways:

* ###Reverse Proxy

  To allow the client application to automatically fail over in the event of a master server becoming unavailable, or the promotion of a new master,
  a reverse proxy can be configured to route traffic depending on the response returned by `https://<ip-address>:8443/v1/server/ha/state` (see above).
  If a server returns `"MASTER"`, then traffic should be routed to that server, otherwise it should not be. The client software should be configured
  to connect to the reverse proxy server and no action is required by the client in the event of a failover. It can take up to 30 seconds for the
  standby to be promoted, so the reverse proxy should retry for at least this period, or the failover time should be reconfigured to be shorter

* ###Re-allocating an Elastic IP on Failover

  If the cloud provider you are using supports Elastic or Floating IPs, then the IP address should be allocated to the HA master, and the client
  application configured to connect to the floating IP address. In the event of a failure of the master node, the standby node will automatically
  be promoted to master, and the floating IP will need to be manually re-allocated to the new master node. No action is required by the client
  in the event of a failover. It is possible to automate the re-allocation of the floating IP if the Brooklyn servers are deployed and managed
  by Brooklyn using the entity `org.apache.brooklyn.entity.brooklynnode.BrooklynCluster`

* ###Client-based failover

  In this scenario, the responsibilty for determining the Brooklyn master server falls on the client application. When configuring the client
  application, a list of all servers in the cluster is passed in at application startup. On first connection, the client application connects to
  any of the members of the cluster to retrieve the HA states (see above). The JSON object returned is used to determine the addresses of all
  members of the cluster, and also to determine which node is the HA master

  In the event of a failure of the master node, the client application should then retrieve the HA states of the cluster from any of the other cluster
  members. This is the same process as when the application first connects to the cluster. The client should refresh its list of cluster memebers
  and determine which node is the HA master

  It is also recommended that the client application periodically checks the status of the cluster and updates its list of addresses. This will
  ensure that failover is still possible if the standby server(s) has been replaced. It also allows additional standby servers to be added at any
  time

### Testing
You can confirm that Brooklyn is running in high availibility mode on the master by logging into the web console at `https://<ip-address>:8443`.
Similarly you can log into the web console on the standby VM where you will see a warning that the server is not the high availability master.

To test a failover, you can simply terminate the process on the first VM and log into the web console on the second VM. Upon launch, Brooklyn will
output its PID to the file `pid.txt`; you can force an immediate (non-graceful) termination of the process by running the following command 
from the same directory from which you launched Brooklyn:

{% highlight bash %}
$ kill -9 $(cat pid.txt)
{% endhighlight %}

It is also possible to check the high availability state of a running Brooklyn server using the following curl command:

{% highlight bash %}
$ curl -k -u myusername:mypassword https://<ip-address>:8443/v1/server/ha/state
{% endhighlight %}

This will return one of the following states:

{% highlight bash %}

"INITIALIZING"
"STANDBY"
"HOT_STANDBY"
"HOT_BACKUP"
"MASTER"
"FAILED"
"TERMINATED"

{% endhighlight %}

Note: The quotation characters will be included in the reply

To obtain information about all of the nodes in the cluster, run the following command against any of the nodes in the cluster:

{% highlight bash %}
$ curl -k -u myusername:mypassword https://<ip-address>:8443/v1/server/ha/states
{% endhighlight %}

This will return a JSON document describing the Brooklyn nodes in the cluster. An example of two HA Brooklyn nodes is as follows (whitespace formatting has been
added for clarity):

{% highlight yaml %}

{
  ownId: "XkJeXUXE",
  masterId: "yAVz0fzo",
  nodes: {
    yAVz0fzo: {
      nodeId: "yAVz0fzo",
      nodeUri: "https://<server1-ip-address>:8443/",
      status: "MASTER",
      localTimestamp: 1466414301065,
      remoteTimestamp: 1466414301000
    },
    XkJeXUXE: {
      nodeId: "XkJeXUXE",
      nodeUri: "https://<server2-ip-address>:8443/",
      status: "STANDBY",
      localTimestamp: 1466414301066,
      remoteTimestamp: 1466414301000
    }
  },
  links: { }
}

{% endhighlight %}

The examples above show how to use `curl` to manually check the status of Brooklyn via its REST API. The same REST API calls can also be used by
automated third party monitoring tools such as Nagios 


