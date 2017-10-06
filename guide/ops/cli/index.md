---
layout: website-normal
title: Client CLI Reference
children:
- cli-ref-guide.md
- cli-usage-guide.md
---


**NOTE:** These documents are for using the Brooklyn Client CLI tool to access a running Brooklyn Server.  For
information on starting on a Brooklyn Server, refer to [Server CLI Reference](../server-cli-reference.html).

## Obtaining the CLI tool

A selection of distributions of the CLI tool, `br`, are available to download from the download site {% if book.brooklyn-version %}
[here](https://repository.apache.org/service/local/artifact/maven/redirect?r=snapshots&g=org.apache.brooklyn&a=brooklyn-client-cli&v={{book.brooklyn-version}}&c=bin&e=zip).
{% else %} here:

* [Windows](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{book.brooklyn-version}}-client-cli-windows.zip)
* [Linux](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{book.brooklyn-version}}-client-cli-linux.tar.gz)
* [OSX](https://www.apache.org/dyn/closer.lua/brooklyn/apache-brooklyn-{{book.brooklyn-version}}-client-cli-macosx.tar.gz)
{% endif %}

Alternatively the CLI tool is available as an executable binary for many more platforms in the Apache Brooklyn
 distribution, under `bin/brooklyn-client-cli/`, with each build in its own subdirectory:

* Mac: `darwin.amd64/`
* Windows 32-bit: `windows.386/`
* Windows 64-bit: `windows.amd64/`
* Linux 32-bit: `linux.386/`
* Linux 64-bit: `linux.amd64/`

The binary is completely self-contained so you can either copy it to your `bin/` directory
or add the appropriate directory above to your path:

    PATH=$PATH:$HOME/apache-brooklyn/bin/brooklyn-client-cli/linux.amd64/


## Documentation


