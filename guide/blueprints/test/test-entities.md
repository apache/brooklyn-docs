---
title: Blueprint Test Entities
title_in_menu: Test Entities
layout: website-normal
---

{% include fields.md %}


## Structural Test Entities

### TestCase
The `TestCase` entity acts as a container for a list of child entities which are started *sequentially*.

{% highlight yaml %}
{% readj example_yaml/entities/testcase-entity.yaml %}
{% endhighlight %}

This can be used to enforce a strict ordering, for example ensuring a sensor has a certain value before attempting to invoke an effector.

Timeouts on child entities should be set relative to the completion of the preceding entity.

The `ParallelTestCase` entity can be added as a child to run a subset of entities in parallel as a single step.


### ParallelTestCase
The `ParallelTestCase` entity acts as a container for a list of child entities which are started in *parallel*.

{% highlight yaml %}
{% readj example_yaml/entities/paralleltestcase-entity.yaml %}
{% endhighlight %}

This can be used to run a subset of entities in parallel as a single step when nested under a `TestCase` entity.

Timeouts on child entities should be set relative to the start of the `ParallelTestCase`.


### LoopOverGroupMembersTestCase
The `LoopOverGroupMembersTestCase` entity is configured with a target group and a test specification. For each member of the targeted group, the test case will create a TargetableTestComponent entity from the supplied test specification and set the components target to be the group member.

{% highlight yaml %}
{% readj example_yaml/entities/loopovergroupmembers-entity.yaml %}
{% endhighlight %}

#### Parameters
- `target` - group who's members are to be tested, specified via DSL. For example, `$brooklyn:entity("tomcat")`. See also the `targetId` parameter.
- `targetId` - alternative to the `target` parameter which wraps the DSL component lookup requiring only the `id` be supplied. For example, `tomcat`. Please note, this must point to a group.
- `test.spec` - The TargetableTestComponent to create for each child.


### InfrastructureDeploymentTestCase
The `InfrastructureDeploymentTestCase` will first create and deploy an infrastructure from the `infrastructure.deployment.spec` config. It will then retrieve a deployment location by getting the value of the infrastructures `infrastructure.deployment.location.sensor` sensor. It will then create and deploy all entities from the `infrastructure.deployment.spec` config to the deployment location.

{% highlight yaml %}
{% readj example_yaml/entities/infrastructuredeploymenttestcase-entity.yaml %}
{% endhighlight %}

#### Parameters

- `infrastructure.deployment.spec` - the infrastructure to be deployed.
- `infrastructure.deployment.entity.specs` - the entities to be deployed to the infrastructure
- `infrastructure.deployment.location.sensor` - the name of the sensor on the infrastructure to retrieve the deployment location


## Validation Test Entities

### TestSensor
The `TestSensor` entity performs an assertion on a specified sensors value.

{% highlight yaml %}
{% readj example_yaml/entities/testsensor-entity.yaml %}
{% endhighlight %}

#### Parameters
- `target` - entity whose sensor will be tested, specified via DSL. For example, `$brooklyn:entity("tomcat")`. See also the `targetId` parameter.
- `targetId` - alternative to the `target` parameter which wraps the DSL component lookup requiring only the `id` be supplied. For example, `tomcat`.
- `sensor` - sensor to evaluate. For example `service.isUp`.
- `timeout` - duration to wait on assertion to return a result. For example `10s`, `10m`, etc
- `assert` - assertion to perform on the specified sensor value. See section on assertions below.

<div class="alert alert-info">
    <strong>Tip:</strong> If the <code>TestSensor</code> is wrapped within a <code>TestCase</code>, 
    <code>ParallelTestCase</code> or <code>LoopOverGroupMembersTestCase</code> that set the target, 
    <strong>you don't need to specify the target</strong>, unless you want to test a different entity.
</div>


### TestEffector
The `TestEffector` entity invokes the specified effector on a target entity. If the result of the effector is a String, it will then perform assertions on the result.
{% highlight yaml %}
{% readj example_yaml/entities/testeffector-entity.yaml %}
{% endhighlight %}

#### Parameters
- `target` - entity whose effector will be invoked, specified via DSL. For example, `$brooklyn:entity("tomcat")`. See also the `targetId` parameter.
- `targetId` - alternative to the `target` parameter which wraps the DSL component lookup requiring only the `id` be supplied. For example, `tomcat`.
- `timeout` - duration to wait on the effector task to complete. For example `10s`, `10m`, etc
- `effector` - effector to invoke, for example `deploy`.
- `params` - parameters to pass to the effector, these will depend on the entity and effector being tested. The example above shows the `url` and `targetName` parameters being passed to Tomcats `deploy` effector.
- `assert` - assertion to perform on the returned result. See section on assertions below.

<div class="alert alert-info">
    <strong>Tip:</strong> If the <code>TestEffector</code> is wrapped within a <code>TestCase</code>, 
    <code>ParallelTestCase</code> or <code>LoopOverGroupMembersTestCase</code> that set the target, 
    <strong>you don't need to specify the target</strong>, unless you want to test a different entity.
</div>


### TestHttpCall
The `TestHttpCall` entity performs a HTTP GET on the specified URL and performs an assertion on the response.
{% highlight yaml %}
{% readj example_yaml/entities/testhttpcall-entity.yaml %}
{% endhighlight %}

#### Parameters
- `url` - URL to perform GET request on, this can use DSL for example `$brooklyn:entity("tomcat").attributeWhenReady("webapp.url")`.
- `timeout` - duration to wait on a HTTP response. For example `10s`, `10m`, etc
- `applyAssertionTo` - The filed to apply the assertion to. For example `status`, `body`
- `assert` - assertion to perform on the response.  See section on assertions below.

<div class="alert alert-info">
    <strong>Tip:</strong> If the <code>TestHttpCall</code> is wrapped within a <code>TestCase</code>, 
    <code>ParallelTestCase</code> or <code>LoopOverGroupMembersTestCase</code> that set the target, 
    <strong>you don't need to specify the target</strong>, unless you want to test a different entity.
</div>


### TestSshCommand
The TestSshCommand runs a command on the host of the target entity.
The script is expected not to run indefinitely, but to return a result (process exit code), along with its
standard out and error streams, which can then be tested using assertions.
If no assertions are explicitly configured, the default is to assert a non-zero exit code.

Either a bash command may be provided in the YAML, or a URL for a script which will be executed.

{% highlight yaml %}
{% readj example_yaml/entities/testsshcommand-entity.yaml %}
{% endhighlight %}

#### Parameters
- `command` - The shell command to execute. (This and `downloadUrl` are mutually exclusive.)
- `downloadUrl` - URL for a script to download and execute. (This and `command` are mutually exclusive.)
- `shell.env` - Map of environment variables to be set.
- `scriptDir` - if `downloadUrl` is used.  The directory on the target host where downloaded scripts should be copied to.
- `runDir` - the working directory where the command or script will be executed on the target host.
- `assertStatus` - Assertions on the exit code of the command or script. See section on assertions below.
- `assertOut` - Assertions on the standard output of the command as a String.
- `assertErr` -  Assertions on the standard error of the command as a String.

<div class="alert alert-info">
    <strong>Tip:</strong> If the <code>TestSshCommand</code> is wrapped within a <code>TestCase</code>, 
    <code>ParallelTestCase</code> or <code>LoopOverGroupMembersTestCase</code> that set the target, 
    <strong>you don't need to specify the target</strong>, unless you want to test a different entity.
</div>


## Assertions

The following conditions are provided by those test entities above that include assertions

- `isNull` - asserts that the actual value is `null`.
- `notNull` - asserts that the actual value is NOT `null`.
- `isEqualTo` - asserts that the actual value equals an expected value.
- `equalTo` - a synonym for `isEqualTo`
- `equals` - a synonym for `isEqualTo`
- `notEqual` - asserts that the actual value does not equal the expected value.
- `matches` - asserts that the actual value matches a [regex pattern](http://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html?is-external=true), for example `".*hello.*"`.
  Note that regular expressions follow the Java defaults, e.g. for [line terminators](http://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html#lt). 
  One can use `"(?m)"` for multi-line mode (so that `^` and `$` also match just after/before line terminators, 
  rather than just the start/end of the entire input sequence). The dotall mode, set with `"(?s)"`, can also 
  be useful (so that `.` matches any character, including line terminators). 
- `containsMatch` - asserts that the value contains a string that matches a regex. It follow the behaviour of 
  the [Matcher.find() method](http://docs.oracle.com/javase/7/docs/api/java/util/regex/Matcher.html#find()).
  This can be useful for simplifying matching in multi-line input.
- `contains` - asserts that the actual value contains the supplied value
- `isEmpty` - asserts that the actual value is an empty string
- `notEmpty` - asserts that the actual value is a non empty string
- `hasTruthValue` - asserts that the actual value has the expected interpretation as a boolean
- `greaterThan` - asserts that the actual value is greater than the expected value according to Java's
  [Comparable](https://docs.oracle.com/javase/8/docs/api/java/lang/Comparable.html) interface. Actual and
  expected must be instances of the same type and implement `Comparable`.
- `lessThan` - asserts that the actual value is less than the expected value according to Java's
  [Comparable](https://docs.oracle.com/javase/8/docs/api/java/lang/Comparable.html) interface. Actual and
  expected must be instances of the same type and implement `Comparable`.

Assertions may be provided as a simple map:

    assert:
      contains: 2 users
      matches: .*[\d]* days.*


If there is the need to make multiple assertions with the same key, the assertions can be specified
as a list of such maps:

    assert:
     - contains: 2 users
     - contains: 2 days
