### Operations

{% feature title="Brooklyn console" %}
Brooklyn runs with a GUI console giving easy access to the
management hierarchy, sensors, and activities.

{% feature_image src="ops-console.png" %}
{% endfeature %}

{% feature title="High availability" %}
Run standby nodes which can optionally automatically promote to master
in the event of master failure. Hot standby nodes can provide additional
read-only access to entity information.
{% endfeature %}

{% feature title="State persistence" %}
Blueprint, catalog, topology and sensor information can be 
automatically persisted to any file system or object store to 
stop Brooklyn and restart resuming where you left off.
{% endfeature %}

{% feature title="REST API" %}
The console is pure JS-REST, and all the data shown in the GUI
is available through a straightforward REST/JSON API.

In many cases, the REST API is simply the GUI endpoint without the
leading `#`.  For instance the data for
`#/v1/applications/` is available at `/v1/applications/`. 
And in all cases, Swagger doc is available in the product.

{% feature_image src="ops-rest.png" %}
{% endfeature %}


{% feature title="Groovy console" %}
With the right permissions, Groovy scripts can be sent via
the GUI or via REST, allowing open-heart surgery on your systems.
(Use with care!) 
{% endfeature feature-item-end.html %}

{% feature title="Versioning" %}
Blueprints in the catalog can be versioned on-the-fly.
Running entities are attached to the version against which
they were launched to preserve integrity, until manual
version updates are performed. 
{% endfeature %}

{% feature title="Deep task information" %}
The console shows task flows in real-time,
including the `stdin` and `stdout` for shell commands,
making it simpler to debug those pesky failures.
{% endfeature %}


