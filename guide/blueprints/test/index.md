---
title: Testing YAML Blueprints
layout: website-normal
children:
- test-entities.md
- usage-examples.md
---

Brooklyn provides a selection of test entities which can be used to validate Blueprints via YAML. The basic building block is a TargetableTestComponent, which is used to resolve a target. There are two different groups of entities that inherit from TargetableTestComponent. The first is structural, which effects how the tests are run, for example by affecting the order they are run in. The second group is validation, which is used to confirm the application is deployed as intended, for example by checking some sensor value.

Structural test entities include:

- `TestCase`  - starts child entities sequentially.
- `ParallelTestCase` - starts child entities in parallel.
- `LoopOverGroupMembersTestCase` - creates a TargetableTestComponent for each member of a group.
- `InfrastructureDeploymentTestCase` - will create the specified Infrastructure and then deploy the target entity specifications there.

Validation test entities include:

- `TestSensor` - perform assertion on a specified sensor.
- `TestEffector` - perform assertion on response to effector call.
- `TestHttpCall` - perform assertion on response to specified HTTP GET Request.
- `TestSshCommand` - test assertions on the result of an ssh command on the same machine as the target entity.
- `TestWinrmCommand` - test assertions on the result of a WinRM command on the same machine as the target entity.
- `TestEndpointReachable` - assert that a TCP endpoint is reachable. The endpoint can be in a 
  number of different formats: a string in the form of `ip:port` or URI format; or a 
  `com.google.common.net.HostAndPort` instance; or a `java.net.URI` instance; or a `java.net.URL` instance.

TargetableTestComponents can be chained together, with the target being inherited by the components children. For example, a ParallelTestCase could be created that has a TestHttpCall as a child. As long as the TestHttpCall itself does not have a target, it will use the target of it's parent, ParallelTestCase. Using this technique, we can build up complex test scenarios.

The following sections provide details on each test entity along with examples of their use.


