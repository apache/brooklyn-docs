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

#### Improved Blueprints

Significant work has gone into making YAML blueprints more powerful.
The DSL is more expressive and a variety of new general-purpose entities,
enrichers and policies have been written.

New general-purpose constructs:

* The `InvokeEffectorOnSensorChange` and `InvokeEffectorOnCollectionSensorChange`
  policies execute effectors on entities whenever a target sensor changes.
* `ProxyEffector` forwards effector invocations from one entity to another.
* `ConditionalEntity` creates an entity based on the truth of a config key
  (e.g. `$brooklyn:scopeRoot().config("enable.loadBalancer")`).
* `OnPublicNetworkEnricher` grants finer control of mapping public
  and private network addresses to sensors.
* `PercentageEnricher` publishes the ratio of two sensors.

New blueprint DSL features:

* `$brooklyn:entity` supports nested function calls;
* `$brooklyn:object` supports parameterised constructors and static factory methods, hugely increasing the range of objects that can be injected into entities;
* `$brooklyn:entityId` returns the target entity's ID; and
* `$brooklyn:self` accesses the resolving task's context entity.


#### Bundled entities

There have been many updates to the entities bundled with Brooklyn. In particular:

* `DynamicCluster` allows configuration of member removal strategies.
* The `Transformer` enricher can be triggered by events on multiple sensors.
* `ZooKeeperNode` publishes main.uri and `ZooKeeperEnsemble` aggregates
  hosts and ports into comma-separated list under `zookeeper.endpoints`.
* `BindDnsServer` listens on all interfaces and supports Centos and RHEL.
* `NginxController` supports proxying with TLS client certificates.
* `RiakNode` optionally configures security groups for intra-node communication
  when supported by the target cloud.
* `PostgreSqlNode` can be configured to grant [user roles](https://www.postgresql.org/docs/9.3/static/role-membership.html).
* `SharedLocationSecurityGroupCustomizer` enables security group 
  configuration in yaml blueprints.
* Feeds no longer poll if their entity is unmanaged.

Several new test-case entities are introduced:

* `TestHttpCall` [supports](https://github.com/apache/brooklyn-server/pull/414) a greatly expanded range of options.
* `TestEndpointReachable` tests that a TCP endpoint can be reached.
* `TestWinrmCommand` tests the success of commands in Windows instances.
* `RelativeEntityTestCase` lets you write test cases that resolve their target from another entity.

Additionally, location customisers can now be attached to entities as
initialisers, rather than having to dig into their `templateOptions`.


#### Brooklyn server

* The REST API requires CSRF headers for non-GET and HEAD requests when
  sessions are in effect.
  See [CsrfTokenFilter]({{ site.path.v }}/0.10.0/misc/javadoc/org/apache/brooklyn/rest/filter/CsrfTokenFilter.html)
  for details.

* The catalogue scanner can be configured with whitelists and blacklists
  of bundle IDs to control which bundles may present applications in the catalogue.

* The Karaf distribution includes equivalents of the
  [cloud explorer commands]({{ site.path.v }}/0.10.0/ops/server-cli-reference.html#cloud-explorer).

* `PerUserEntitlementManager` transforms the "user" keyword into an
  entitlement to everything but `ROOT` and `SEE_ALL_SERVER_INFO`.

* Myriad performance and reliability improvements.


#### New CLI commands

The CLI has better integration with the Brooklyn server catalogue. New commands
exist to `list` its items, `show` verbose descriptions of entries and to `delete`
them. SSL certificate chain and hostname verification can be disabled by running
with the `--skipSslChecks` flag.


### Backwards Compatibility

To address limitations in the handling of configuration and inheritance
the following changes were made:

* [major] Config is now resolved against the ancestor where it is defined e.g. attributeWhenReady;

* [major] ConfigMap.submap is no longer supported for entity config;
findKeys has been introduced, and the method is available on the main sub-interfaces where it was used

* [major] Location config is treated like Entities and Adjuncts; it respects inheritance
as a consequence of this, some persisted usage information is no longer available.

Please refer to pull requests
[#340](https://github.com/apache/brooklyn-server/pull/340)
and [#281](https://github.com/apache/brooklyn-server/pull/281)
for more details on the above three incompatibilities.

* [major] `DynamicGroup` only filters entities in the same application
  rather than the whole management context.

* [major] `VanillaSoftwareProcess` commands are no longer inherited by its children.

* [major] Non-zero results from the various pre- and post- commands for
`SoftwareProcess` cause entity failure, where previously they were silently accepted.

* [minor] Entities using `org.apache.brooklyn.entity.software.base.AbstractSoftwareProcessDriver`
execute pre- and post-launch commands when restarting.

* [minor] `ClassCoercionException` has moved package. The old one was deleted
to prevent errors inadvertently trying to catch it.

* [minor] Default config key values are now coerced to the right type when accessed.
Previously coercion only applied to values set, so if a default value was accessed, the caller would get the
value and type of the default value, not coerced to the type of the config key.
This was inconsistent with cases where a value is set for the config key, as callers in that case will get the
value coerced to the type of the config key. This was a bug as callers should always be able to expect
the config value to be of the declared type, consistently across default values and explicitly set values.

    As an example, if a config key is typed (e.g. `port`) and a caller uses code such as `$brooklyn:config` to access
that value, previously they would see the numeric value if the value comes from a default;
if that is what is being expected it is an error as a JSON map for `PortRange` would be returned if a config value is set,
but the erroneous usage might not have been noticed if the port only ever came from a default value.
The fix in this case is to use `$brooklyn:attributeWhenReady` if the caller wants the actual value selected from the range
(through port inferencing done e.g. in `SoftwareProcess` entities),
or to declare the sensor of type `int` if they do not want port ranges and inferencing to be supported.

* [minor] `SimpleShellCommandTest` is renamed `TestSshCommand`.

* [minor] The `/{entity}/spec` API endpoint responds with unquoted
  `text/x-yaml` rather than json.

For changes in prior versions, please refer to the release notes for
[0.9.0]({{ site.path.v }}/0.9.0/misc/release-notes.html).
