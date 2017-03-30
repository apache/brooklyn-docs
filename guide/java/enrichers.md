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

Transforms attributes of an entity.

{% highlight yaml %}
brooklyn.enrichers:
- type: org.apache.brooklyn.enricher.stock.Transformer
  brooklyn.config:
    enricher.sourceSensor: $brooklyn:sensor("urls.tcp.string")
    enricher.targetSensor: $brooklyn:sensor("urls.tcp.withBrackets")
    enricher.targetValue: $brooklyn:formatString("[%s]", $brooklyn:attributeWhenReady("urls.tcp.string"))
{% endhighlight %}

#### Propagator

[`org.apache.brooklyn.enricher.stock.Propagator`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/enricher/stock/Propagator.html)

Use propagator to duplicate one sensor as another, giving the supplied sensor mapping.
The other use of Propagator is where you specify a producer (using `$brooklyn:entity(...)` as below)
from which to take sensors; in that mode you can specify `propagate` as a list of sensors whose names are unchanged, instead of (or in addition to) this map.

{% highlight yaml %}
brooklyn.enrichers:
- type: org.apache.brooklyn.enricher.stock.Propagator
  brooklyn.config:
    producer: $brooklyn:entity("cluster")
- type: org.apache.brooklyn.enricher.stock.Propagator
  brooklyn.config:
    sensorMapping:
      $brooklyn:sensor("url"): $brooklyn:sensor("org.apache.brooklyn.core.entity.Attributes", "main.uri")
{% endhighlight %}

####	Custom Aggregating

[`org.apache.brooklyn.enricher.stock.Aggregator`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/enricher/stock/Aggregator.html)

Aggregates multiple sensor values (usually across a tier, esp. a cluster) and performs a supplied aggregation method to them to return an aggregate figure, e.g. sum, mean, median, etc.

{% highlight yaml %}
brooklyn.enrichers:
- type: org.apache.brooklyn.enricher.stock.Aggregator
  brooklyn.config:
    enricher.sourceSensor: $brooklyn:sensor("webapp.reqs.perSec.windowed")
    enricher.targetSensor: $brooklyn:sensor("webapp.reqs.perSec.perNode")
    enricher.aggregating.fromMembers: true
    transformation: average
{% endhighlight %}

#### Joiner

[`org.apache.brooklyn.enricher.stock.Joiner`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/enricher/stock/Joiner.html)

Joins a sensor whose output is a list into a single item joined by a separator.

{% highlight yaml %}
brooklyn.enrichers:
- type: org.apache.brooklyn.enricher.stock.Joiner
  brooklyn.config:
    enricher.sourceSensor: $brooklyn:sensor("urls.tcp.list")
    enricher.targetSensor: $brooklyn:sensor("urls.tcp.string")
    uniqueTag: urls.quoted.string
{% endhighlight %}

####	Delta Enricher

[`org.apache.brooklyn.policy.enricher.DeltaEnricher`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/policy/enricher/DeltaEnricher.html)

Converts absolute sensor values into a delta.

####	Time-weighted Delta

[`org.apache.brooklyn.enricher.stock.YamlTimeWeightedDeltaEnricher`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/enricher/stock/YamlTimeWeightedDeltaEnricher.html)

Converts absolute sensor values into a delta/second.

{% highlight yaml %}
brooklyn.enrichers:
- type: org.apache.brooklyn.enricher.stock.YamlTimeWeightedDeltaEnricher
  brooklyn.config:
    enricher.sourceSensor: reqs.count
    enricher.targetSensor: reqs.per_sec
    enricher.delta.period: 1s
{% endhighlight %}

####	Rolling Mean

[`org.apache.brooklyn.policy.enricher.RollingMeanEnricher`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/policy/enricher/RollingMeanEnricher.html)

Converts the last *N* sensor values into a mean.

####	Rolling Time-window Mean

[`org.apache.brooklyn.policy.enricher.RollingTimeWindowMeanEnricher`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/policy/enricher/RollingTimeWindowMeanEnricher.html)

Converts the last *N* seconds of sensor values into a weighted mean.

#### Http Latency Detector

[`org.apache.brooklyn.policy.enricher.RollingTimeWindowMeanEnricher.HttpLatencyDetector`](https://brooklyn.apache.org/v/latest/misc/javadoc/org/apache/brooklyn/policy/enricher/HttpLatencyDetector.html)

An Enricher which computes latency in accessing a URL.

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

{% highlight yaml %}
brooklyn.enrichers:
- type: org.apache.brooklyn.enricher.stock.Transformer
  brooklyn.config:
    enricher.producer: $brooklyn:entity("load.balancer")
    enricher.sourceSensor: $brooklyn:sensor("urls.tcp.string")
    enricher.targetSensor: $brooklyn:sensor("urls.tcp.withBrackets")
    enricher.targetValue: |
      $brooklyn:formatString("[%s]", $brooklyn:attributeWhenReady("urls.tcp.string"))
{% endhighlight %}

It is important to note that the value supplied to `enricher.producer` must be immediately resolvable. While it would be valid
DSL syntax to write:

{% highlight yaml %}
enricher.producer: brooklyn:entity($brooklyn:attributeWhenReady("load.balancer.entity"))
{% endhighlight %}

(assuming the `load.balancer.entity` sensor returns a Brooklyn entity), this will not function properly because `enricher.producer`
will unsuccessfully attempt to get the supplied entity immediately.
