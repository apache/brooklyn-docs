---
section: Control Apache Brooklyn
section_type: inline
section_position: 3
---

## Control Apache Brooklyn

Apache Brooklyn has a web console which can be used to control the application. The Brooklyn log will contain the 
address of the management interface:

<pre>
INFO  Started Brooklyn console at http://127.0.0.1:8081/, running classpath://brooklyn.war
</pre>

By default it can be accessed by opening [127.0.0.1:8081](http://127.0.0.1:8081){:target="_blank"} in your web browser.

The rest of this getting started guide uses the Apache Brooklyn command line interface (CLI) tool, `br`. 
This tool is both distributed with Apache Brooklyn or can be downloaded using the most appropriate link for your OS:

* [Windows](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{site.brooklyn-version}}-client-cli-windows.zip)
* [Linux](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{site.brooklyn-version}}-client-cli-linux.tar.gz)
* [OSX](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{site.brooklyn-version}}-client-cli-macosx.tar.gz)

For details on the CLI, see the [Client CLI Reference](../ops/cli/) page. 