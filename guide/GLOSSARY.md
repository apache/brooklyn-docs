## Apache jclouds
An open source Java library that provides a consistent interface to many
clouds. Apache Brooklyn uses Apache jclouds as its core cloud abstraction.

## Autonomic
Refers to the self-managing characteristics of distributed computing resources,
adapting to unpredictable changes while hiding intrinsic complexity to
operators and users.

## Blueprint
A description of an application or system, which can be used for its automated
deployment and runtime management. The blueprint describes a model of the
application (i.e. its components, their configuration, and their
relationships), along with policies for runtime management. The blueprint can
be described in YAML or Java.

## Effector
Effectors are tools Apache Brooklyn provides, that allow you to manipulate the live entities within an application.
They are operations applied on entities.

## Enricher
Generates new events or sensor values (metrics) for an entity, usually by aggregating 
or modifying data from one or more other sensors.

## Entity
A component of an application or system. This could be a physical component, a
service, a grouping of components, or a logical construct describing part of an
application/system. It is a "managed element" in autonomic computing parlance.

## Location
A server or resource to which Apache Brooklyn can deploy applications

## Policy
Part of an autonomic management system, performing runtime management. A policy
is associated with an entity; it normally manages the health of that entity
or an associated group of entities (e.g. HA policies or auto-scaling policies).
A policy performs actions on entities, based on their sensor values and policy configuration.

## Sensor
A sensor is a property, or attribute of an Apache Brooklyn entity, updated in real-time.

## YAML
A human-readable data format. See the [Wikipedia article](http://en.wikipedia.org/wiki/YAML) for more information.

## CAMP and TOSCA

OASIS Cloud Application Management for Platforms (CAMP) and OASIS Topology and
Orchestration Specification for Cloud Applications (TOSCA) are specifications
that aim to standardise the portability and management of cloud applications.