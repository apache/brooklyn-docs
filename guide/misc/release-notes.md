---
layout: website-normal
title: Release Notes
---

## Version {{ site.brooklyn-version }}

{% if SNAPSHOT %}
**You are viewing a SNAPSHOT release (master branch), so this list is in progress!**
{% endif %}

Thanks go to our community for their improvements, feedback and guidance, and
to Brooklyn's commercial users for funding much of this development.

### New Features

#### Workflows

Apache Brooklyn now has a powerful workflow engine and syntax for defining entities, effectors, sensors, and policies.
It supports longhand and shorthand syntax, conditions, loops, error-handling, variables, a large set of built-in step types, and 
the ability to define custom step types.md).

```yaml
- type: some-entity
  brooklyn.initializers:
  - type: workflow-sensor
    brooklyn.config:
      sensor: count-how-often-other_sensor-is-published
      triggers:
        - other_sensor
      steps:
        - let integer x = ${entity.sensor.x} + 1 ?? 0
        - return ${x}
```

#### Workflow Enitity (workflow-entity)

Brooklyn now supports a `workflow-entity` where `start` / `stop` are defined by workflow.

#### Kubectl Task factory, Docker effector and Docker Sensor

This is a practical and highly customizable way to externalize effectors and sensors to containers run on a Kubernetes cluster or Docker container.

```yaml
name: container-effector
services:
  - type: 'org.apache.brooklyn.entity.stock.BasicStartable:1.1.0-SNAPSHOT'
    brooklyn.initializers:
      - type: org.apache.brooklyn.tasks.kubectl.ContainerEffector
        brooklyn.config:
          name: container-effector
          description: Very simple container effector
          shell.env:
            hello: world-amp
          image: perl
          imagePullPolicy: IfNotPresent
          args:
            - echo
            - hello
```

#### Logbook Viewer

Logbook exposes through a new rest API endpoint the server logs. It’s packaged with two different logstore implementation:
- Static logfiles (default)
- A ElasticSearch instance

Logs can be seen in the about page but also as part of each task execution, as each task has it’s own ID. As task can create new sub-task, is possible to see the logs of all the child-task when filtering by the creator.


#### Updated to Apache Karaf 4.3.6

Karaf updates:

This release is an important release on the Karaf 4.3.x series containing:
- upgrade to Pax Logging 2.0.14 with log4j 2.17.1 (fixing CVE-2021-44832)
- prepare JDK 18 support
- fix deployment issue by upgrading to Apache Felix FileInstall 3.7.4
- and much more!

The Release Notes are available here: https://issues.apache.org/jira/secure/ReleaseNote.jspa?projectId=12311140&version=12351123

#### Groups Change Policy

New policy for adding policies, enrichers, and initializers to entities as the join dynamic groups.

#### Connection tag

Inspired by the Hashicorp Terraform `connection` element and added a `connection` tag that encapsulates connection details. When declared on an entity, any SSH steps will use the details to establish a connection and execute

#### Add support setup default initializers for all deployment

This looks up a new configuration options called brooklyn.deployment.initializers (comma separated list). If specified on a Brooklyn instance, all deployments will load and execute these initializers.

`brooklyn.deployment.initializers=org.apache.brooklyn.core.effector.AddDeploySensorsInitializer`

#### Persistence import/export API

Introducing an API for persistence import/export feature.
This is intended for file based persistence stores and as a parameter, it takes the location of root of the persistence store to be imported.

Invoking the operation will merge the new data to the currently existing store. The process is as follows:
- new temporary management context is created with the persistence store to be imported
- memento of that persistence store is captured
- bundles from the persistence store are installed in the active management context - this deals with bundles/types in the catalog and locations
- contents of relevant directories (policies, enrichers, etc). are written to the active management context. These are used for the deployed applications
- rebind method adds the deployed applications to the active management context without having to reset the full management context/restart the server

#### New ChildrenBatchEffector

Adding a new effector to call a inner effector in all the children entities where the effector is inserted in batches of a parametrized size.

#### Add a Secret object which can be used to capture a secret

This can be used wherever we need extra assurance that credentials are not accidentally logged or shown in ui

### Security Fixes

#### Mitigate CVE-2023-1370

see: https://security.snyk.io/vuln/SNYK-JAVA-NETMINIDEV-3369748

#### Prevent zip slip

Avoid extracting zip files trying to extract files outside the provided path.
https://security.snyk.io/research/zip-slip-vulnerability

#### Update xstream to 1.4.19 remediating CVE-2021-43859

#### Updated to json-smart 1.4.7

Mitigates [CVE-2021-27568 ](https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2021-27568) cataloged by [Snyk](https://security.snyk.io/vuln/SNYK-JAVA-NETMINIDEV-1078499) as **Critical**

### Bump xstream to 1.4.18 due to high level vulnerabilities

Snyk detected the next vulnerabilities on prev version:
```
  ✗ Arbitrary Code Execution [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569176] in com.thoughtworks.xstream:xstream@1.4.17
  ✗ Arbitrary Code Execution [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569177] in com.thoughtworks.xstream:xstream@1.4.17
  ✗ Arbitrary Code Execution [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569178] in com.thoughtworks.xstream:xstream@1.4.17
  ✗ Arbitrary Code Execution [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569179] in com.thoughtworks.xstream:xstream@1.4.17
  ✗ Arbitrary Code Execution [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569180] in com.thoughtworks.xstream:xstream@1.4.17
  ✗ Arbitrary Code Execution [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569181] in com.thoughtworks.xstream:xstream@1.4.17
  ✗ Arbitrary Code Execution [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569182] in com.thoughtworks.xstream:xstream@1.4.17
  ✗ Remote Code Execution (RCE) [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569183] in com.thoughtworks.xstream:xstream@1.4.17
  ✗ Arbitrary Code Execution [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569185] in com.thoughtworks.xstream:xstream@1.4.17
  ✗ Arbitrary Code Execution [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569186] in com.thoughtworks.xstream:xstream@1.4.17
  ✗ Arbitrary Code Execution [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569187] in com.thoughtworks.xstream:xstream@1.4.17
  ✗ Server-Side Request Forgery (SSRF) [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569190] in com.thoughtworks.xstream:xstream@1.4.17
  ✗ Server-Side Request Forgery (SSRF) [High Severity][https://snyk.io/vuln/SNYK-JAVA-COMTHOUGHTWORKSXSTREAM-1569191] in com.thoughtworks.xstream:xstream@1.4.17
```

#### Bumping org.freemaker due a high severity vulnerability

Detected with snyk:
https://snyk.io/vuln/SNYK-JAVA-ORGFREEMARKER-1076795

### Backwards Compatibility

No changes since 1.0.0 should affect compatibility with 1.1.0


For changes in prior versions, please refer to the release notes for 
[1.0.0]({{ site.path.v | relative_url }}/1.0.0/misc/release-notes.html).
