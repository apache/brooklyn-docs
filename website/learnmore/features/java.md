### Java

{% feature  title="Discoverable configuration" %}
Config keys, sensors, and effectors can be defined on the classes
such that they are automatically discoverable at runtime.
Type information, parameters, documentation, and default values
are returned through the REST API and shown in the GUI.   
{% endfeature %}

{% feature title="Type hierarchy" %}
Use interfaces and mix-ins to share and inherit behavior in a strongly typed way.

{% feature_image src="java-hierarchy.png" %}
{% endfeature %}

{% feature title="Sensor feeds" %}
Fluent builder-style API's are included for collecting sensor information
from REST endpoints, SSH commands, JMX connectors, and more. 
{% endfeature %}

{% feature title="Task libraries" %}
Fluent builder-style task libraries are included for building activity
chains which run in parallel or sequentially,
executing SSH, REST, or arbitrary Java commands.
Task status, result, hierarchies, and errors are exposed through the REST API and in the GUI. 
{% endfeature %}
