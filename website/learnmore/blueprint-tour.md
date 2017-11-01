---
layout: website-normal
title: A Quick Tour of a Brooklyn Blueprint
usermanual-pdf-exclude: true
title_in_menu: Blueprint Tour
---

{% tour %}

{% block title="Describe your application", description="Start by giving it a name, optionally adding a version and other metadata. The format is YAML -- a human-friendly extension to JSON -- following the [CAMP]({{ site.path.website }}/learnmore/theory.html#standards) standard." %}
<span class="ann_highlight"># java chatroom with ruby chatbot and couchbase backend (example)</span>    
name: Chatroom with Chatbot
services:
{% endblock %}

{% block title="Compose blueprints", description="Choose your building blocks from a large curated catalog, and compose them together to form new blueprints you can deploy and share. Customize with config keys, such as the initial size and, for Couchbase, the data buckets required." %}
<span class="ann_highlight">- type: couchbase-cluster</span>
  initialSize: 3
  createBuckets: [{ bucket: chatroom }]
  id: chat-couchbase
{% endblock %}

{% block title="Run scripts and recipes", description="Use bash, with variables supplied by Brooklyn; or Chef recipes, with attributes passed from config; or package managers, dockerfiles, etc." %}
- type: bash-server
  launch.command: |
<span class="ann_highlight">    wget http://example.com/couchbase-chat/chat-bot/{server.rb,Gemfile,install_ruby_and_libs.sh}
    bash install_ruby_and_libs.sh
    ruby ./server.rb $COUCHBASE_URL</span>
{% endblock %}

{% block title="Inject dependencies", description="Connect entities with each other using *sensors* published at runtime to give just-in-time resolution for shell variables, template expansion, REST calls, and any other "happens-before" or "on-change" behaviour." %}
  shell.env:
    COUCHBASE_URL:
<span class="ann_highlight">      $brooklyn:entity("chat-couchbase").
        attributeWhenReady("couchbase.cluster.connection.url")</span>
{% endblock %}

{% block title="Configure locations", description="Give generic VM properties or specific images and flavors. Networking topologies and geographic constraints are also supported." %}
  provisioning.properties:
<span class="ann_highlight">    osFamily: ubuntu
    minRam: 4gb</span>
{% endblock %}

{% block title="Extend using Java", description="Create new entities, policies, and "effector" operations using Java or JVM bridges to many languages, workflow systems, or PaaSes. Add new blueprints to the catalog, dynamically, with versions and libraries handled under the covers automatically with OSGi." %}
- type: <span class="ann_highlight">org.apache.brooklyn.entity.webapp.ControlledDynamicWebAppCluster:1.1.0</span>
  war: http://example.com/couchbase-chat/chatroom.war
  java.sysprops:
    chat.db.url: $brooklyn:entity("chat-couchbase").attributeWhenReady("couchbase.cluster.connection.url")
{% endblock %}

{% block title="Attach management logic", description="Set up policies which subscribe to real-time metric sensors to scale, throttle, failover, or follow-the-{sun,moon,action,etc}. Cloud should be something that *applications* consume, not people!" %}
  brooklyn.policies:
  - type: <span class="ann_highlight">autoscaler</span>
    brooklyn.config:
      metric: $brooklyn:sensor("webapp.reqs.perSec.windowed.perNode")
      metricLowerBound: 400
      metricUpperBound: 600
{% endblock %}

{% block title="Run across many locations", description="Blueprints are designed for portability. Pick from dozens of clouds in hundreds of datacenters. Or machines with fixed IP addresses, localhost, Docker on [Clocker](http://clocker.io), etc. And you're not limited to servers: services, PaaS, even networks can be locations." %}
location:
  <span class="ann_highlight">jclouds:aws-ec2</span>:
    region: us-east-1
    identity: <i>AKA_YOUR_ACCESS_KEY_ID</i>
    credential: <i>[access-key-hex-digits]</i>
{% endblock %}

{% endtour %}
