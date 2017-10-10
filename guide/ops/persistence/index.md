---
title: Persistence
layout: website-normal
children:
- { section: Configuration }
- { section: File-based Persistence }
- { section: Object Store Persistence }
- { section: Rebinding to State }
- { section: Writing Persistable Code }
- { section: Persisted State Backup }
---
# {{ page.title }}

By default Brooklyn persists its state to storage so that a server can be restarted 
without loss or so a high availability standby server can take over.

Brooklyn can persist its state to one of two places: the file system, or to an [object store](https://en.wikipedia.org/wiki/Object_storage)
of your choice.


# Configuration

To configure persistence, edit the file `org.apache.brooklyn.osgilauncher.cfg` in the `etc`
directory of your Brooklyn instance. The following options are available:

`persistMode` - This is the mode in which persistence is running, in and is set to `AUTO` by default. The possible values are:

* `AUTO` - will rebind to any existing state, or start up fresh if no state;
* `DISABLED` - will not read or persist any state;
* `REBIND` - will rebind to the existing state, or fail if no state available;
* `CLEAN` - will start up fresh (removing any existing state)

`persistenceDir` - This is the directory to which Apache Brooklyn reads and writes its persistence data. The default location depends
on your installation method. Checkout [this page](../paths.html) for more information.

`persistenceLocation` - This is the location for an object store to read and write persisted state.

`persistPeriod` - This is an interval period which can be set to reduce the frequency with which persistence
is carried out, for example `1s`.


# File-based Persistence

Apache Brooklyn starts with file-based persistence by default, saving data in the [persisted state folder](../paths.html).
For the rest of this document we will refer to this location as `%persistence-home%`.

If there is already data at `%persistence-home%/data`, then a backup of the directory will 
be made. This will have a name like `%persistence-home%/backups/%date%-%time%-jvyX7Wis-promotion-igFH`.
This means backups of the data directory will be automatically created each time Brooklyn 
is restarted (or if a standby Brooklyn instances takes over as master).

The state is written to the given path. The file structure under that path is:

* `./catalog/`
* `./enrichers/`
* `./entities/`
* `./feeds/`
* `./locations/`
* `./nodes/`
* `./plane/`
* `./policies/`

In each of those directories, an XML file will be created per item - for example a file per
entity in `./entities/`. This file will capture all of the state - for example, an
entity's: id; display name; type; config; attributes; tags; relationships to locations, child 
entities, group membership, policies and enrichers; and dynamically added effectors and sensors.


# Object Store Persistence

Apache Brooklyn can persist its state to any Object Store API supported by [Apache jclouds](https://jclouds.apache.org/) including 
[S3](https://aws.amazon.com/s3), [Swift](http://docs.openstack.org/developer/swift) and [Azure](https://azure.microsoft.com/services/storage/). 
This gives access to any compatible Object Store product or cloud provider including AWS-S3, 
SoftLayer, Rackspace, HP and Microsoft Azure. For a complete list of supported
providers, see [jclouds](http://jclouds.apache.org/reference/providers/#blobstore).

To configure the Object Store, add the credentials to `brooklyn.cfg` such as:

```properties
brooklyn.location.named.aws-s3-eu-west-1=aws-s3:eu-west-1
brooklyn.location.named.aws-s3-eu-west-1.identity=ABCDEFGHIJKLMNOPQRSTU
brooklyn.location.named.aws-s3-eu-west-1.credential=abcdefghijklmnopqrstuvwxyz1234567890ab/c
``` 

or:

```properties
brooklyn.location.named.softlayer-swift-ams01=jclouds:openstack-swift:https://ams01.objectstorage.softlayer.net/auth/v1.0
brooklyn.location.named.softlayer-swift-ams01.identity=ABCDEFGHIJKLM:myname
brooklyn.location.named.softlayer-swift-ams01.credential=abcdefghijklmnopqrstuvwxyz1234567890abcdefghijklmnopqrstuvwxyz12
brooklyn.location.named.softlayer-swift-ams01.jclouds.keystone.credential-type=tempAuthCredentials
``` 

Then edit the `persistenceLocation` to point at this object store: `softlayer-swift-ams01`.

# Rebinding to State

When Brooklyn starts up pointing at existing state, it will recreate the entities, locations 
and policies based on that persisted state.

Once all have been created, Brooklyn will "manage" the entities. This will bind to the 
underlying entities under management to update the each entity's sensors (e.g. to poll over 
HTTP or JMX). This new state will be reported in the web-console and can also trigger 
any registered policies.


## Handling Rebind Failures

If rebind fails fail for any reason, details of the underlying failures will be reported 
in the [`brooklyn.debug.log`](../paths.html). This will include the entities, locations or policies which caused an issue, and in what 
way it failed. There are several approaches to resolving problems.

1) Determine Underlying Cause

Go through the log and identify the likely areas in the code from the error message.

2) Seek Help

 Help can be found by contacting the Apache Brooklyn mailing list.

3) Fix-up the State

The state of each entity, location, policy and enricher is persisted in XML. 
It is thus human readable and editable.

After first taking a backup of the state, it is possible to modify the state. For example,
an offending entity could be removed, or references to that entity removed, or its XML 
could be fixed to remove the problem.


4) Fixing with Groovy Scripts

The final (powerful and dangerous!) tool is to execute Groovy code on the running Brooklyn 
instance. If authorized, the REST api allows arbitrary Groovy scripts to be passed in and 
executed. This allows the state of entities to be modified (and thus fixed) at runtime.

If used, it is strongly recommended that Groovy scripts are run against a disconnected Brooklyn
instance. After fixing the entities, locations and/or policies, the Brooklyn instance's 
new persisted state can be copied and used to fix the production instance.


# Writing Persistable Code

The most common problem on rebind is that custom entity code has not been written in a way
that can be persisted and/or rebound.

The rule of thumb when implementing new entities, locations, policies and enrichers is that 
all state must be persistable. All state must be stored as config or as attributes, and must be
serializable. For making backwards compatibility simpler, the persisted state should be clean.

Below are tips and best practices for when implementing an entity in Java (or any other 
JVM language).

How to store entity state:

* Config keys and values are persisted.
* Store an entity's runtime state as attributes.
* Don't store state in arbitrary fields - the field will not be persisted (this is a design
  decision, because Brooklyn cannot intercept the field being written to, so cannot know
  when to persist).
* Don't just modify the retrieved attribute value (e.g. `getAttribute(MY_LIST).add("a")` is bad).
  The value may not be persisted unless setAttribute() is called.
* For special cases, it is possible to call `entity.requestPerist()` which will trigger
  asynchronous persistence of the entity.
* Overriding (and customizing) of `getRebindSupport()` is discouraged - this will change
  in a future version.


How to store policy/enricher/location state:

* Store values as config keys where applicable.
* Unfortunately these (currently) do not have attributes. Normally the state of a policy 
  or enricher is transient - on rebind it starts afresh, for example with monitoring the 
  performance or health metrics rather than relying on the persisted values.
* For special cases, you can annotate a field with `@SetFromFlag` for it be persisted. 
  When you call `requestPersist()` then values of these fields will be scheduled to be 
  persisted. *Warning: the `@SetFromFlag` functionality may change in future versions.*

Persistable state:

* Ensure values can be serialized. This (currently) uses xstream, which means it does not
  need to implement `Serializable`.
* Always use static (or top-level) classes. Otherwise it will try to also persist the outer 
  instance!
* Any reference to an entity or location will be automatically swapped out for marker, and 
  re-injected with the new entity/location instance on rebind. The same applies for policies,
  enrichers, feeds, catalog items and `ManagementContext`.

Behaviour on rebind:

* By extending `SoftwareProcess`, entities get a lot of the rebind logic for free. For 
  example, the default `rebind()` method will call `connectSensors()`.
  See [`SoftwareProcess` Lifecycle](/blueprints/java/entities.html)
  for more details.
* If necessary, implement rebind. The `entity.rebind()` is called automatically by the
  Brooklyn framework on rebind, after configuring the entity's config/attributes but before 
  the entity is managed.
  Note that `init()` will not be called on rebind.
* Feeds will be persisted if and only if `entity.addFeed(...)` was called. Otherwise the
  feed needs to be re-registered on rebind. *Warning: this behaviour may change in future version.*
* All functions/predicates used with persisted feeds must themselves be persistable - 
  use of anonymous inner classes is strongly discouraged.
* Subscriptions (e.g. from calls to `subscribe(...)` for sensor events) are not persisted.
  They must be re-registered on rebind.  *Warning: this behaviour may change in future version.*

Below are tips to make backwards-compatibility easier for persisted state: 

* Never use anonymous inner classes - even in static contexts. The auto-generated class names 
  are brittle, making backwards compatibility harder.
* Always use sensible field names (and use `transient` whenever you don't want it persisted).
  The field names are part of the persisted state.
* Consider using Value Objects for persisted values. This can give clearer separation of 
  responsibilities in your code, and clearer control of what fields are being persisted.
* Consider writing transformers to handle backwards-incompatible code changes.
  Brooklyn supports applying transformations to the persisted state, which can be done as 
  part of an upgrade process.


# Persisted State Backup

### File system backup

When using the file system it is important to ensure it is backed up regularly.

One could use `rsync` to regularly backup the contents to another server.

It is also recommended to periodically create a complete archive of the state.
A simple mechanism is to run a CRON job periodically (e.g. every 30 minutes) that creates an
archive of the persistence directory, and uploads that to a backup 
facility (e.g. to S3).

Optionally, to avoid excessive load on the Brooklyn server, the archive-generation could be done 
on another "data" server. This could get a copy of the data via an `rsync` job.

An example script to be invoked by CRON is shown below:

    DATE=`date "+%Y%m%d.%H%M.%S"`
    BACKUP_FILENAME=/path/to/archives/back-${DATE}.tar.gz
    DATA_DIR=/path/to/base/dir/data
    
    tar --exclude '*/backups/*' -czvf $BACKUP_FILENAME $DATA_DIR
    # For s3cmd installation see http://s3tools.org/repositories
    s3cmd put $BACKUP_FILENAME s3://mybackupbucket
    rm $BACKUP_FILENAME


### Object store backup

Object Stores will normally handle replication. However, many such object stores do not handle 
versioning (i.e. to allow access to an old version, if an object has been incorrectly changed or 
deleted).

The state can be downloaded periodically from the object store, archived and backed up. 

An example script to be invoked by CRON is shown below:

    DATE=`date "+%Y%m%d.%H%M.%S"`
    BACKUP_FILENAME=/path/to/archives/back-${DATE}.tar.gz
    TEMP_DATA_DIR=/path/to/tempdir
    
    brooklyn copy-state \
            --persistenceLocation named:my-persistence-location \
            --persistenceDir /path/to/bucket \
            --destinationDir $TEMP_DATA_DIR

    tar --exclude '*/backups/*' -czvf $BACKUP_FILENAME $TEMP_DATA_DIR
    # For s3cmd installation see http://s3tools.org/repositories
    s3cmd put $BACKUP_FILENAME s3://mybackupbucket
    rm $BACKUP_FILENAME
    rm -r $TEMP_DATA_DIR
