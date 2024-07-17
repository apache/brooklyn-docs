---
title: YAML Blueprint Reference
layout: website-normal
---

## Root Elements

* `name`: human readable names
* `services`: a list of `ServiceSpecification` elements
* `location` (or `locations` taking a list): a `LocationSpecification` element as a string or a map


## Service Specification Elements

Within the `services` block, a list of maps should be supplied, with each map
defining a `ServiceSpecification`.  Each `ServiceSpecification` should declare the
service `type` (synonyms `serviceType` and `service_type`), indicating what type of 
service is being specified there.  The following formats are supported for
defining types:

* `com.acme.brooklyn.package.JavaEntityClass`
* `java:com.acme.brooklyn.package.JavaEntityClass`
* `java-entity-class` (where this has been added to the [catalog](/guide/blueprints/catalog))

A reference of some of the common service `type` instances used is included in a section below.

Within the `ServiceSpecification`, other key-value pairs can be supplied to customize
the entity being defined, with these being the most common:

* `id`: an ID string, used to refer to this service

* `location` (or `locations`): as defined in the root element 
  
* `brooklyn.config`: configuration key-value pairs passed to the service entity being created;
  complex values are supported if they are JSON-deserializable beans that have been added as registered types

* `brooklyn.children`: a list of `ServiceSpecifications` which will be configured as children of this entity

* `brooklyn.policies`: a list of policies, each as a map described with their `type` and their `brooklyn.config` as keys

* `brooklyn.enrichers`: a list of enrichers, each as a map described with their `type` and their `brooklyn.config` as keys;
  see the keys declared on individual enrichers; 
  also see [this enricher example](example_yaml/test-app-with-enrichers-slightly-simpler.yaml) for a detailed and commented illustration
  <!-- TODO assert that this yaml maches the yaml we test against -->

* `brooklyn.initializers`: a list of `EntityInitializer` instances to be constructed and run against the entity, 
  each as a map described with their `type` (Java or a registered type in the catalog) and JSON-serializable fields. 
  
  An `EntityInitializer` can perform arbitrary customization to an entity whilst it is being constructed,
  such as adding dynamic sensors and effectors.
  
  Some common initializers are:
  
  * `org.apache.brooklyn.core.effector.ssh.SshCommandEffector`: takes a `name` and `command`,
    and optionally a map of named `parameters` to their `description` and `defaultValue`,
    to define an effector with the given name implemented by the given SSH command
    (on an entity which as an ssh-able machine)

  * `org.apache.brooklyn.core.sensor.ssh.SshCommandSensor`: takes a `name` and `command`,
    and optionally a `period` (e.g. `1h`) or `triggers` (a sensor name, or list containing sensor names or
    maps of the form `{entity: id, sensor: name}`), to create a sensor feed which populates the sensor with
    the given name by running the given command (on an entity which as an ssh-able machine);
    this also takes an optional `type` to coerce the output from YAML or JSON
    (if the `---` document separator is used, only the output after the last such separator is coerced,
    allowing output to be verbose until the final section) 

  * `org.apache.brooklyn.tasks.kubectl.ContainerSensor`: takes a `name` and `image`,
    and optionally either `bashScript` or `command`,
    and optionally the same `period` and `triggers` and `type` as `SshCommandSensor`, 
    to create a sensor feed which runs the given container to populate the sensor

  * `org.apache.brooklyn.core.sensor.windows.WinRmCommandSensor`: For a command supplied via WinRm. Takes a `name`, `command`,
    and optionally a `period` or `triggers`, and optionally `executionDir`, 
    to create a sensor feed which populates the sensor with
    the given name by running the given command (on an entity which as an WinRM-able machine);
    _`"~"` will use the default execution directory for the WinRm session which is usually `%USERPROFILE%`_
  
  When specifying the type of an initializer, registered types (added to the catalog) are preferred,
  but Java types are permitted.
  
  Advanced note:  When implementing an initializer in Java, it is preferred to rely on standard Jackson serialization techniques to initialize fields, 
  i.e. have a no-arg constructor and fields which can be specified in YAML.
  However it is permitted for backwards compatibility, to supply configuration under a `brooklyn.config` key;
  via a public constructor taking a single `ConfigBag` (or sometimes a `Map`) 
  where the `brooklyn.config` key-values are passed in.
  This approach has several constraints however. 
  The config inheritance modes which are used on entities and other spec types are not recognised here.
  If the type is added to the catalog and referred to by its registered type name,
  or if registered types are being passed as config,
  the class must support JSON deserialization of `brooklyn.config`,
  and that is strongly recommended since Apache Brooklyn v1.1.
  This can be done by ensuring a no-arg constructor is defined and
  supplying a `@JsonSetter("brooklyn.config") initializeConfig(Map<String,Object)` method.
  There are convenience abstract classes in `EntityInitializers` which can be useful for more complicated configurations.

* `brooklyn.parameters`: documents a list of typed parameters the entity accepts.
  These define config keys exposed on the type, including metadata for prompting a user to supply them.
  All config keys inherited from supertypes are available as parameters by default, 
  and their properties (e.g. default values) can be overridden. 
  Parameters (config keys) have the following properties:
  * `name` (required): identifier by which to reference the parameter when setting
    or retrieving its value
  * `label`: an identifier string to present to the user when prompting for a value, same as `name` if empty
  * `description`: short text describing the parameter behaviour/usage, presented
    to the user
  * `type`: the type of the parameter, one of `string`, `integer`, `long`, `float`,
    `double`, `timestamp`, `duration`, `port`, or a fully qualified Java type name;
    the default is `string`;
    obvious coercion is supported so 
    `timestamp` accepts most common ISO date formats, `duration` accepts `5m`, and port accepts `8080+`
  * `default`: a default value; this will be coerced to the declared `type`
  * `pinned`: mark the parameter as pinned (always displayed) for the UI. The default is `true`
    (unless an ancestor sets false; config keys from Java types are _not_ pinned)
  * `constraints`: a list of constraints the parameter should meet;
    for details, see [Entity Configuration](/guide/blueprints/entity-configuration.html#config-key-constraints).

  A shorthand notation is also supported where just the name of the parameter can be supplied
  as an item in the list, with the other values being unset or the default.
  See `displayName` in the following example for an illustration of this:

  ~~~ yaml
  brooklyn.parameters:
    # user.age parameter is required, pinned and fully specified
    - name: user.age
      type: integer
      label: Age
      description: the age of the user
      pinned: true
      constraints:
      - required
    # user.name is optional, is not pinned and has a default
    - name: user.name
      default: You
      pinned: false
    # shorthand notation: displayName will be an optional config of type string with no default
    - displayName
  ~~~

  Referencing the parameters from within java classes is identical to using config keys. In yaml it's
  usually referenced using `$brooklyn:scopeRoot().config("displayName")`. See below for more details on scopes.

* `brooklyn.tags`: a list of tag objects which should be attached to the entity.

Entities (and policies and enrichers) will typically accept additional key-value pairs
as per the config keys (parameters) they expose.  In some cases they may accept other fields
(where fields in a Java class are annotated `@SetFromFlag` although this is discouraged),
but undeclared config is only accepted in the `brooklyn.config` map.
Global config can be passed in either at the root of the `ServiceSpecification` 
or in a root `brooklyn.config` section.

Initializers and custom types used as config/parameters are treated as beans, with fields at the root.
However in many cases initializers also accept configuration passed in a `brooklyn.config` section.
To accept expressions using the Brooklyn DSL (`$brooklyn:xxx`) in fields of beans,
the field type should be declared as a `WrappedValue<T>`, where `T` is the desired type.
(Config key values will always accept the Brooklyn DSL without this, but fields will not.)


## Location Specification Elements

<!-- TODO - expand this, currently it's concise notes -->

In brief, location specs are supplied as follows, either for the entire application (at the root)
or for a specific `ServiceSpecification`:

    location:
      jclouds:aws-ec2:
        region: us-east-1
        identity: AKA_YOUR_ACCESS_KEY_ID
        credential: <access-key-hex-digits>

Or in many cases it can be in-lined:

    location: localhost
    location: named:my_openstack
    location: aws-ec2:us-west-1

For the first immediately, you'll need password-less ssh access to localhost.
For the second, you'll need to define a named location in `brooklyn.properties`,
using `brooklyn.location.named.my_openstack....` properties.
For the third, you'll need to have the identity and credentials defined in
`brooklyn.properties`, using `brooklyn.location.jclouds.aws-ec2....` properties.

If specifying multiple locations, e.g. for a fabric:

    locations:
    - localhost
    - named:my_openstack
    - aws-ec2:us-east-2   # if credentials defined in `brooklyn.properties
    - jclouds:aws-ec2:
        region: us-east-1
        identity: AKA_YOUR_ACCESS_KEY_ID
        credential: <access-key-hex-digits>

If you have pre-existing nodes, you can use the `byon` provider, either in this format:

    location:
      byon:
        user: root
        privateKeyFile: ~/.ssh/key.pem
        hosts:
        - 11.22.33.44
        - 11.22.33.45
        - brooklyn@55.66.77.88
        - brooklyn@55.66.77.89

or:

    location:
      byon:
        user: root
        privateKeyFile: ~/.ssh/key.pem
        hosts: "{11.22.33.{44,45},brooklyn@55.66.77.{88-89}"

You cannot use glob expansions with the list notation, nor can you specify per-host
information apart from user within a single `byon` declaration.
However you can combine locations using `multi`:

    location:
      multi:
        targets:
        - byon:
            user: root
            privateKeyFile: ~/.ssh/key.pem
            hosts:
            - 11.22.33.44
            - 11.22.33.45
        - byon:
            privateKeyFile: ~/.ssh/brooklyn_key.pem
            hosts: brooklyn@55.66.77{88-89}


## DSL Commands

Dependency injection other powerful references and types can be built up within the YAML using the
concise DSL defined here:
 
* `$brooklyn:attributeWhenReady("sensor")` will store a future which will be blocked when it is accessed,
  until the given `sensor` from this entity "truthy" (i.e. non-trivial, non-empty, non-zero) value
  (see below on `component` for looking up values on other sensors) 
* `$brooklyn:config("key")` will insert the value set against the given key at this entity (or nearest ancestor);
  can be used to supply config at the root which is used in multiple places in the plan
* `$brooklyn:sensor("sensor.name")` returns the given sensor on the current entity if found, or an untyped (Object) sensor;
  `$brooklyn:sensor("com.acme.brooklyn.ContainingEntityClass", "sensor.name")` returns the strongly typed sensor defined in the given class

* `$brooklyn:entity("ID")` refers to a Brooklyn entity with the given ID;
  you can then access the following subfields,
  using the same syntax as defined above but with a different reference entity,
  e.g. `$brooklyn:entity("ID").attributeWhenReady("sensor")`:
  * `.attributeWhenReady("sensor")`
  * `.config("key")`
  * `.sensor("sensor.name")`
* `$brooklyn:component("ID")` is also supported as a synonym for the above
  (optionally taking a scope in the first argument but this is deprecated from the DSL as the scope is
  redundant with the methods below); note methods prefer matching entities nearer the origin,
  and only look in the same application unless otherwise noted (e.g. `application("ID")`),
  and can be chained, e.g. `application("other_app").entity("node_in_other_app").config("key_there")`
* `$brooklyn:self()` will return the current entity
* `$brooklyn:parent()` will return the entity's parent, failing if it is an application
* `$brooklyn:root()` will return the topmost entity (the application)
* `$brooklyn:scopeRoot()` will return the root entity in the current plan scope.
  For catalog items it's the topmost entity in the plan, for application plans it is the same as
  `$brooklyn:root()`.
* `$brooklyn:child("ID")`: looks for any immediate child with the given `ID`
* `$brooklyn:application("ID")`: looks for any application (root) with the given `ID`
* `$brooklyn:descendant("ID")`: looks for any descendant excluding members with the given `ID`
* `$brooklyn:member("ID")`: looks for any descendant including members with the given `ID`
* `$brooklyn:sibling("ID")`: looks for any child of the entity's parent with the given `ID`

* `$brooklyn:formatString("pattern e.g. %s %s", "field 1", "field 2")` returns a future which creates the formatted string
  with the given parameters, where parameters may be strings *or* other tasks such as `attributeWhenReady`
* `$brooklyn:external("provider", "token")` return the value stored for `token` in the externalized configuration store identified as `provider`
* `$brooklyn:urlEncode("val")` returns a future which creates a string with the characters escaped
  so it is a valid part of a URL. The parameter can be a string *or* another task. For example,
  `$brooklyn:urlEncode($brooklyn:config(\"mykey\"))`. It uses "www-form-urlencoded" for the encoding,
  which is appropriate for query parameters but not for some other parts of the URL (e.g. space is encoded as `'+'`).
* `$brooklyn:literal("string")` returns the given string as a literal (suppressing any `$brooklyn:` expansion)
* `$brooklyn:object(Map)` creates an object, using keys `type` to define the java type,
  and either `object.fields` or `brooklyn.config` to supply bean/constructor/flags to create an instance
* `$brooklyn:entitySpec(Map)` returns a new `ServiceSpecification` as defined by the given `Map`,
  but as an `EntitySpec` suitable for setting as the value of `ConfigKey<EntitySpec>` config items
  (such as `dynamiccluster.memberspec` in `DynamicCluster`); this is often not needed, 
  if the `EntitySpec` is expected by context and can be coerced from a map
  using the simple Jackson deserialization in the `EntitySpec` class
  (this is similar to CAMP but is not as extensive, and other formats are not supported in coercion;
  if there are any issues with a direct map, consider wrapping it in the `$brooklyn:entitySpec` DSL)

Parameters above can be supplied either as strings or as lists and maps in YAML, and the `$brooklyn:` syntax can be used within those parameters.  

**Note:** The DSL is always supported for the values of config keys on entities. The DSL is supported in many other places also, but not all, depending on how the value is used there. For instance some aspects of a location or initializer may need to be retrieved without an entity context and so do not support DSL.


## Some Powerful YAML Entities

All entities support configuration via YAML, but these entities in particular 
have been designed for general purpose use from YAML.  Consult the Javadoc for these
elements for more information:

* **Workflow Software** in `WorkflowSoftwareProcess`: makes it very easy to build entities
  using workflow to install, launch, stop, and check running
* **Vanilla Software** in `VanillaSoftwareProcess`: makes it very easy to build entities
  which use `bash` commands to install and the PID to stop and restart
* `DynamicCluster`: provides resizable clusters given a `dynamiccluster.memberspec` set with `$brooklyn.entitySpec(Map)` as described above 
* `DynamicFabric`: provides a set of homogeneous instances started in different locations,
  with an effector to `addLocation`, i.e. add a new instance in a given location, at runtime

## Notable Tags

Some tags are used by convention and in the UI for special purposes.
These are:

* `ui-composer-annotation`: text (interpreted as markdown without HTML support) which will be displayed on a node in the Blueprint Composer,
  or a map containing a key with the `text` and optionally any/all of `{x, y, width, height, background, style, styleInnerDiv}` for displaying it.
  The display of these can be toggled in the Blueprint Composer by selecting "Layers > Annotations".
  This is illustrated in the following blueprint:

  ~~~ yaml
  name: Annotation Sample
  services:
  - type: server
    brooklyn.tags:
      - ui-composer-annotation: A simple default annotation
      - ui-composer-annotation:
          text: >-
            Shown below, yellow text, centered with CSS. Because it's long, scroll bars horizontally and vertically shown when
            needed.
          styleInnerDiv: 'margin: auto; color: yellow;'
          y: 120
  - type: server
    brooklyn.tags:
      - ui-composer-annotation:
          text: |
            ## Big Example
            A **red** tag at _right_, using markdown, in a big box.
          width: 300
          height: 200
          x: 220
          y: 0
          background: '#ffcccc'
          style: 'font-size: 9px;'
  ~~~

* `ui-composer-hints`: a collection of tags typically on an entity definitiion providing hints to composers,
  including `config-widgets` (setting custom widgets to render fields) and `config-quick-fixes` (proposals for fixing common errors);
  see the code for the Blueprint Composer for more details

* `ui-effector-hints`: a tag containing a single-entry map with this key will constrain how effectors are 
  presented in the UI. The value should be a map containing one or more of the following keys:
  * `exclude-regex`: a regex string matched against effector names to exclude them from listing in the "Effectors" tag 
  * `include-regex`: a regex string per above to explicitly include matching names which would be excluded by the above 


## Predicate DSL

In contexts where a `DslPredicate` or `DslEntityPredicate` is expected, the `$brooklyn:object`
DSL can be used to construct any suitable implementation, such as using factory methods from `EntityPredicates`.
In many cases, however, a simplified YAML DSL can be used, 
as defined by the Jackson deserialization rules on the `DslPredicate`.

In its simplest form this can be a map containing the test or tests, e.g.:

```
equals: north
```

This will result in a `Predicate` which returns true if asked to `test("north")`,
and false otherwise.  The full set of individual tests are:

* `equals: <object>`, to test java object equality, attempting type coercion if necessary
* `regex: <string|number>`
* `glob: <string|number>`
* `not: <test>`, to return whether the indicated `<test>` fails
* `check: <test>`, to apply the indicated `<test>` (mainly useful to structure checks involving retargeting, e.g. nested `key` lookups)
* `when: <presence>`, where `<presence>` is one of the values described below
* `assert: <presence|test>`, to cause the test to fail fast if the value does not meet the indicated `<presence>` or `<test>`, 
  throwing an exception with details rather than merely returning false  
* `less-than: <object>`, for strings and primitives, computed using "natural ordering",
  numeric order for numbers and digit sequences within numbers (`"9" < "10"`),
  and ASCII-lexicographic comparison elsewhere (`"a" < "b"`);
  otherwise if both arguments are the same type, or one a subtype of the other, and both comparable,
  it will use that type's compare method;
  otherwise if one side side is JSON, it will attempt coercion to the other argument's type;
  and otherwise it will return false
* `greater-than: <object>`, as above 
* `less-than-or-equal-to: <object>` as above
* `greater-than-or-equal-to: <object>`, as above
* `size: <test>`, for lists, maps, and strings, to apply the `<test>` to the size/length,
  e.g. `size: 0` for empty, `size: { greater-than: 0 }` or `not: { size: 0 }` for non-empty
* `has-element: <test>`, for lists, checks whether any entry satisifes the `<test>`
  (same for sets; and for maps, applying `<test>` to each key-value entry as a two-element list) 
* `in-range: <range>`, where `<range>` is a list of two numbers, e.g. `[0,100]` (always inclusive)
* `java-instance-of: <test|registered-type>`, where the `<test>` is applied to the underlying java class of the
  value being tested and all super-classes and super-interfaces, 
 allowing strings to match the fully qualified or simple name of the class or any super,
  and string tests (e.g. glob, regex) applied to the fully-qualified class name;
  if the argument is a string it is also tested as a registered type and instance-of applied against the
  the type assignment of the underlying java class of the value being tested with the
  underlying java type of that registered type

Where a `<test>` is required, unless otherwise indicated a string or integer can be supplied to imply an `equals` test.

Two composite tests are supported, both taking a list of other `<test>` objects 
(as a list of YAML maps):

* `any: <list of tests>`, testing that any of the tests in the list are true (logical `"or"`)
* `all: <list of tests>`, testing that all of the tests in the list are true (logical `"and"`)


### Presence, When, and Assert

The `<presence>` object allows for testing of edge case values, 
to distinguish between values which are unavailable
(e.g. a sensor which has not been published, or a config which is unset), 
values which are null,
and values which are "truthy" (non-empty, non-false, per `$brooklyn:attributeWhenReady`).
Permitted values for this test are:

* `absent`: value cannot be resolved (not even as null)
* `absent_or_null`: value is null or cannot be resolved
* `present`: value is available, but might be null
* `present_non_null`: value is available and non-null (but might be 0 or empty)
* `truthy`: value is available and ready/truthy (eg not false or empty)
* `falsy`: value is unavailable or not ready/truthy (eg not false or empty)
* `always`: always returns true
* `never`: always returns false

The key `when` can be used with any of these values to cause the check to return false
if the presence requirement is not met.

The key `assert` can be used with any of these values to cause the check to fail immediately,
throwing an exception with details, if the presence requirement is not met.
This key can also take a nested condition (but not an implicit equals).
Typically `assert` is used to ensure that the condition is testing the right target
and to provide feedback in the form of an error message if some conditions are not met.
Whereas the other keys will simply return false with little or feedback 
unless `trace` logging is enabled, a `<presence>` or `<test>` in an `assert` key
will provide information about why the condition has failed.
This can be useful to inform the user if they provided invalid input and for debugging
(to make it easier to see why conditions are returning false).

As an example, consider the following condition:

```
condition:
  index: 0
  glob: a*
  assert: present_not_null
```

If given a list with at least one element, it will return true if the first element starts with `a`,
and false if there is a first element which does not start with `a`.
If the input is an empty list, or not a list, or contains `null` as the first entry,
the `assert: present_not_null` line causes it to throw an exception saying which of these is the case.
(Without this line the condition will simply return `false` in any of these cases.)


### Error Handling

Two additional options are available for checking errors or any Java `Throwable` type:

* `error-field: <name>`, to retarget the test against the value of the field `<name>` on the
  throwable, trying first with `target.getName()` then with `target.name`;
  this is useful for inspecting the `message` or other fields such as `statusCode` that
  might be present on an error class
* `error-cause: <test>`, to retarget the test against the throwable or its cause,
  recursively, finding the first instance which matches the test;
  this is useful where exceptions have been wrapped at the point where they need to test

These are especially powerful in conjunction with `java-instance-of` and `regex` or `glob`.
For example the following will match any exception which is, or is caused by, an
`HttpResponseException` whose toString (message) contains `www.acme.com` 
and where the `getStatusCode()` method returns an HTTP error code (400 or higher).
This could be used, for instance, to retry workflow steps in the case of specific
errors on specific servers.

```
condition:
  error-cause:
    java-instance-of: HttpResponseException
    glob: *www.acme.com*
    check:
      error-field: statusCode
      greater-than-or-equal-to: 400
```


### Entity Tests

To assist with tests on an `Entity` or `Location`, additional keys are supported on
the `DslPredicate` via `DslEntityPredicate`, which allow "retargetting" the expression under test.
These expressions change the focus of the tests defined in the predicate as follows:

* `target: <expression>`: to specify a value to test, resolved relative to the "context entity"
  (the one being tested, if appropriate, or otherwise the evaluating entity where the predicate is defined); 
  this can be a DSL expression such as `$brooklyn:config("key")` 
  or a keyword, currently `locations` or `children` or `tags`, to evaluate the tests
  against the location(s) or children of that entity,
  and the singular (`location`, `child`, or `tag`) to check any child on the current test
  (implicitly wrapping all other fields in `has-element`, so long as `has-element` isn't implicitly set)
* `config: <string>`: indicates that the tests should be applied to the value of config key
  `<string>` on the context entity, location, or policy
* `sensor: <string>`: indicates that the tests should be applied to the value of sensor
  `<string>` on the context entity

For either `config` or `sensor`, there is a default test for truthiness (cf DSL `availableWhenReady`).
For everything else, it is an error if a test is omitted.

Additionally on entities and locations, there is a test:

* `tag: <test>`: indicates that `<test>` should be applied to all tags on the context entity, location, or policy,
  passing if any tag passes the test; this is an alternative to specifying `tag` or `tags` as the `target`
  (if that is supplied along with a `tag: <test>`, the predicate will check whether any tag has a tag)


### Lists, Maps and JSON Behaviour

To facilitate testing against collections (e.g. `target: locations`, or a map or complex type)
the following retargetting keys are supported:

* `key: <object>`: retargets the tests to the value at the indicated key in a map
* `filter: <test>`: retargets the tests to be a sub-list of entries matching `<test>`
  (for lists and sets, and with maps treated as per `has-element`) 
* `index: <integer>`: retargets the tests to the value at the indicated index in a list or set or map (for maps returning a two-element list, per `has-element`)
* `jsonpath: <string>`: applies the given JSON-Path `<string>`, e.g. `key.subkey[1].list[0]`, to the JSON serialization of the value under test,
  and retargets to the resulting value, or list of values if `..` or `*` is used
  (some strict JSON-Path expressions require a `$.` prefix before key names and `$` before `[` expressions;
  they are accepted but are unnecessary and will be inferred if omitted)


### Examples

##### Entity Config

The following will test whether an entity has a config `region`
starting with `us-`, for example to filter within a `DynamicGroup`:

```
config: region
glob: us-*
```

(Instead of the `glob`, writing `regex: us-.*` would be equivalent.)


##### Location Config

Sometimes we may wish to apply a similar filter, but for entities where any location matches the test.
We can use a `target` and the `has-element` test:

```
target: locations
has-element:
  config: region
  glob: us-*
```

We can instead use the shorthand `location` which implies `has-element`:

```
target: location
config: region
glob: us-*
```



##### Date Comparison

Given a config `expiry` of type `Instant` (or related date/time type),
this will check that the date is on or after Jan 1 2000:

```
config: expiry
greater-than-or-equal-to: 2000-01-01
```


##### Present, Absent, and Null Sensors

This will select entities which have a non-trivial ("truthy") value for the sensor "ready":

```
sensor: ready
```

This will select entities which have _not_ published the sensor "ready":

```
sensor: ready
when: absent
```

And this will select entities where that sensor _has_ been published,
but its value is null, false, or empty.

```
sensor: ready
all:
- when: present
- when: falsy
```

