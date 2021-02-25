---
title: Application, Parent and Membership
layout: website-normal
toc: ../guide_toc.json
categories: [use, guide, defining-applications]
---

All entities have a ***parent*** entity, which creates and manages it, with one important exception: *applications*.
Application entities are the top-level entities created and managed externally, manually or programmatically.

Applications are typically defined in Brooklyn as an ***application descriptor***. 
This is a Java class specifying the entities which make up the application,
by extending the class ``AbstractApplication``, and specifying how these entities should be configured and managed.

All entities, including applications, can be the parent of other entities. 
This means that the "child" is typically started, configured, and managed by the parent.
For example, an application may be the parent of a web cluster; that cluster in turn is the parent of web server processes.
In the management console, this is represented hierarchically in a tree view.

A parallel concept is that of ***membership***: in addition to one fixed parent,
an entity may be a ***member*** of zero or more ***groups*** (a "group" is a special kind of entity).
Membership of a group can be used for whatever purpose is required; 
it is commonly used to manage a collection of entities together for one purpose.

For example, a group could be used to indicate the targets for a load balancer, getting
the address of each. These targets do not need to have the same parent (e.g. the members
may have been deployed in different locations, where the 'parent' hierarchy mirrors the
different locations).

Another example would be deployment of a set of VMs where there is a "sidecar" logging
process on each VM. The parent hierarchy could be a top-level cluster with a child entity
per VM. Under each of these VM entities there could be two child entities for the two
processes. There could then be a "group" entity whose members were all the sidecar
logger entities.
