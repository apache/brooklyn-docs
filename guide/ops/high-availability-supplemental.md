---
title: High Availability (Supplemental)
layout: website-normal
---

This document supplements the High Availability documentation available [here](http://brooklyn.apache.org/v/latest/ops/high-availability.html)
and provides an example of how to configure a pair of Apache Brooklyn servers to run in master-standby mode with a shared NFS datastore

### Prerequisites
- Two VMs (or physical machines) have been provisioned
- NFS or another suitable file system has been configured and is available to both VMs*
- An NFS folder has been mounted on both VMs at `/mnt/brooklyn-persistence` and both machines can write to the folder

\* Brooklyn can be configured to use either an object store such as S3, or a shared NFS mount. The recommended option is to use an object
store as described in the [Object Store Persistence](./persistence/#object-store-persistence) documentation. For clarity, a shared NFS folder
is assumed in this example

### Launching
To start, download and install the latest Apache Brooklyn release on both VMs following the 'OSX / Linux' section
of the [Running Apache Brooklyn](../start/running.html#install-apache-brooklyn) documentation

On the first VM, which will be the master node, run the following to start Brooklyn in high availability mode:

{% highlight bash %}
$ bin/brooklyn launch --highAvailability master --persist auto --persistenceDir /mnt/brooklyn-persistence
{% endhighlight %}

Once Brooklyn has launched, on the second VM, run the following command to launch Brooklyn in standby mode:

{% highlight bash %}
$ bin/brooklyn launch --highAvailability auto --persist auto --persistenceDir /mnt/brooklyn-persistence
{% endhighlight %}

### Testing
You can now confirm that Brooklyn is running in high availibility mode on the master by logging into the web console at `http://<ip-address>:8081`.
Similarly you can log into the web console on the standby VM where you will see a warning that the server is not the high availability master.
To test a failover, you can simply terminate the process on the first VM and log into the web console on the second VM. Upon launch, Brooklyn will
output its PID to the file `pid.txt`; you can terminate the process by running the following command from the same directory from which you 
launched Brooklyn:

{% highlight bash %}
$ kill -9 $(cat pid.txt)
{% endhighlight %}

It is also possiblity to check the high availability state of a running Brooklyn server using the following curl command:

{% highlight bash %}
$ curl -u myusername:mypassword http://<ip-address>:8081/v1/server/ha/state
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
$ curl -u myusername:mypassword http://<ip-address>:8081/v1/server/ha/states
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
      nodeUri: "http://<server1-ip-address>:8081/",
      status: "MASTER",
      localTimestamp: 1466414301065,
      remoteTimestamp: 1466414301000
    },
    XkJeXUXE: {
      nodeId: "XkJeXUXE",
      nodeUri: "http://<server2-ip-address>:8081/",
      status: "STANDBY",
      localTimestamp: 1466414301066,
      remoteTimestamp: 1466414301000
    }
  },
  links: { }
}

{% endhighlight %}

The examples above show how to use `curl` to manually check the status of Brooklyn via its REST API. The same REST API calls can also be used by
automated third party monitoring tools such as Monit 

### Failover
When running as a HA standby node, each standby Brooklyn server (in this case there is only one standby) will check the shared persisted state
every 1 second to determine the state of the HA master. If no heartbeat has been recorded for thirty seconds, then an election will be performed
and one of the standby nodes will be promoted to master. At this point all requests should be directed to the new master node

In the event that tasks - such as the provisioning of a new entity - are running when a failover occurs, the new master will display the current
state of the entity, but will not resume its provisioning or re-run any partially completed tasks. In this case it will usually be necesarry
to remove the node and reprovision it

### Client Configuration
It is the responsibility of the client to connect to the master Brooklyn server. This can be accomplished in a variety of ways:

* **Reverse Proxy**

  To allow the client application to automatically fail over in the event of a master server becoming unavailable, or the promotion of a new master,
  a reverse proxy can be configured to route traffic depending on the response returned by `http://<ip-address>:8081/v1/server/ha/state` (see above).
  If a server returns `"MASTER"`, then traffic should be routed to that server, otherwise it should not be. The client software should be configured
  to connect to the reverse proxy server and no action is required by the client in the event of a failover
* **Elastic IP with manual failover**

  If the cloud provider you are using supports Elastic or Floating IPs, then the IP address should be allocated to the HA master, and the client
  application configured to connect to the floating IP address. In the event of a failure of the master node, the standby node will automatically
  be promoted to master, and the floating IP will need to be manually re-allocated to the new master node. No action is required by the client
  in the event of a failover
* **Client-based failover**

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
