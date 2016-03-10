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

The CLI tool, `br`,  is included in the Apache Brooklyn distribution, under `bin/brooklyn-client-cli/`.
The tool is an executable binary available for many platforms, with each build in its own subdirectory:

* Mac: `darwin.amd64/`
* Windows 32-bit: `windows.386/`
* Windows 64-bit: `windows.amd64/`
* Linux 32-bit: `linux.386/`
* Linux 64-bit: `linux.amd64/`

The binary is completely self-contained so you can either copy it to your `bin/` directory
or add the appropriate directory above to your path:

    PATH=$PATH:$HOME/apache-brooklyn/bin/brooklyn-client-cli/linux.amd64/


## Documentation

{% include list-children.html %}
