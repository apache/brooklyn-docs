---
title: Enrichers
layout: website-normal
toc: ../guide_toc.json
categories: [use, guide, defining-applications]
---

Enrichers provide advanced manipulation of an entity's sensor values.
See below for documentation of the stock enrichers available in Apache Brooklyn.

#### Transformer

[`org.apache.brooklyn.enricher.stock.Transformer`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/enricher/stock/Transformer.html)

Takes a source sensor and modifies it in some way before publishing the result in a new sensor. See below an example using `$brooklyn:formatString`.

!CODEFILE "example_yaml/enricher-transformer.yaml"

#### Propagator

[`org.apache.brooklyn.enricher.stock.Propagator`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/enricher/stock/Propagator.html)

Use propagator to duplicate one sensor as another, giving the supplied sensor mapping.
The other use of Propagator is where you specify a producer (using `$brooklyn:entity(...)` as below)
from which to take sensors; in that mode you can specify `propagate` as a list of sensors whose names are unchanged, instead of (or in addition to) this map.

!CODEFILE "example_yaml/enricher-propagator.yaml"

#### Custom Aggregating

[`org.apache.brooklyn.enricher.stock.Aggregator`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/enricher/stock/Aggregator.html)

Aggregates multiple sensor values (usually across a tier, esp. a cluster) and performs a supplied aggregation method to them to return an aggregate figure, e.g. sum, mean, median, etc.

!CODEFILE "example_yaml/enricher-aggregator.yaml"

There are a number of additional configuration keys available for the Aggregators:

| Configuration Key                 | Default | Description                                                         |
|-----------------------------------|---------|---------------------------------------------------------------------|
| enricher.transformation.untyped   | list    | Specifies a transformation, as a function from a collection to the value, or as a string matching a pre-defined named transformation, such as 'average' (for numbers), 'sum' (for numbers), 'isQuorate' (to compute a quorum), 'first' (the first value, or null if empty), or 'list' (the default, putting any collection of items into a list) |
| quorum.check.type                 |         | The requirement to be considered quorate -- possible values: 'all', 'allAndAtLeastOne', 'atLeastOne', 'atLeastOneUnlessEmpty', 'alwaysHealthy'", "allAndAtLeastOne" |
| quorum.total.size                 | 1       | The total size to consider when determining if quorate              |

#### Joiner

[`org.apache.brooklyn.enricher.stock.Joiner`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/enricher/stock/Joiner.html)

Joins a sensor whose output is a list into a single item joined by a separator.

!CODEFILE "example_yaml/enricher-joiner.yaml"

There are a number of additional configuration keys available for the joiner:

| Configuration Key                 | Default | Description                                                         |
|-----------------------------------|---------|---------------------------------------------------------------------|
| enricher.joiner.separator         | ,       | Separator string to insert between each argument                    |
| enricher.joiner.keyValueSeparator | =       | Separator string to insert between each key-value pair              |
| enricher.joiner.joinMapEntries    | false   | Whether to add map entries as key-value pairs or just use the value |
| enricher.joiner.quote             | true    | Whether to bash-escape each parameter and wrap in double-quotes     |
| enricher.joiner.minimum           | 0       | Minimum number of elements to join; if fewer than this, sets null   |
| enricher.joiner.maximum           | null    | Maximum number of elements to join (null means all elements taken)  |

####	Delta Enricher

[`org.apache.brooklyn.policy.enricher.DeltaEnricher`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/policy/enricher/DeltaEnricher.html)

Converts an absolute sensor into a delta sensor (i.e. the difference between the current and previous value)

####	Time-weighted Delta

[`org.apache.brooklyn.enricher.stock.YamlTimeWeightedDeltaEnricher`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/enricher/stock/YamlTimeWeightedDeltaEnricher.html)

Converts absolute sensor values into a difference over time. The `enricher.delta.period` indicates the measurement interval.

!CODEFILE "example_yaml/enricher-time-weighted-delta.yaml"

####	Rolling Mean

[`org.apache.brooklyn.policy.enricher.RollingMeanEnricher`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/policy/enricher/RollingMeanEnricher.html)

Transforms a sensor into a rolling average based on a fixed window size. This is useful for smoothing sample type metrics, such as latency or CPU time

#### Rolling Time-window Mean

[`org.apache.brooklyn.policy.enricher.RollingTimeWindowMeanEnricher`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/policy/enricher/RollingTimeWindowMeanEnricher.html)

Transforms a sensor's data into a rolling average based on a time window. This time window can be specified with the config key `confidenceRequired` - Minimum confidence level (ie period covered) required to publish a rolling average (default `8d`).

#### Http Latency Detector

[`org.apache.brooklyn.policy.enricher.RollingTimeWindowMeanEnricher.HttpLatencyDetector`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/policy/enricher/HttpLatencyDetector.html)

An Enricher which computes latency in accessing a URL, normally by periodically polling that URL. This is then published in the sensors `web.request.latency.last` and `web.request.latency.windowed`.

There are a number of additional configuration keys available for the Http Latency Detector:

| Configuration Key                 | Default | Description                                                          |
|-----------------------------------|---------|----------------------------------------------------------------------|
| latencyDetector.url               |         | The URL to compute the latency of                                    |
| latencyDetector.urlSensor         |         | A sensor containing the URL to compute the latency of                |
| latencyDetector.urlPostProcessing |         | Function applied to the urlSensor value, to determine the URL to use |
| latencyDetector.rollup            |         | The window size (in duration) over which to compute                  |
| latencyDetector.requireServiceUp  | false   | Require the service is up                                            |
| latencyDetector.period            | 1s      | The period of polling                                                |

#### Combiner

[`org.apache.brooklyn.enricher.stock.Combiner`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/enricher/stock/Combiner.html)

Can be used to combine the values of sensors.  This enricher should be instantiated using `Enrichers.builder().combining(..)`.
This enricher is only available in Java blueprints and cannot be used in YAML.

#### Note On Enricher Producers

If an entity needs an enricher whose source sensor (`enricher.sourceSensor`) belongs to another entity, then the enricher
configuration must include an `enricher.producer` key referring to the other entity.

For example, if we consider the Transfomer from above, suppose that `enricher.sourceSensor: $brooklyn:sensor("urls.tcp.list")`
is actually a sensor on a different entity called `load.balancer`. In this case, we would need to supply an
`enricher.producer` value.

!CODEFILE "example_yaml/enricher-transformer.yaml"

It is important to note that the value supplied to `enricher.producer` must be immediately resolvable. While it would be valid
DSL syntax to write:

```yaml
enricher.producer: brooklyn:entity($brooklyn:attributeWhenReady("load.balancer.entity"))
```

(assuming the `load.balancer.entity` sensor returns a Brooklyn entity), this will not function properly because `enricher.producer`
will unsuccessfully attempt to get the supplied entity immediately.
