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

The CLI tool, `br`,  is included in the Apache Brooklyn distribution, in bin/brooklyn-client-cli-0.9.0-SNAPSHOT.
The tool is an executable binary (written in Go), and is distributed in a number of builds for a variety of platforms
and architectures, each build in its own subdirectory:

    darwin.386    freebsd.386    linux.386    netbsd.386     openbsd.386    windows.386
    darwin.amd64  freebsd.amd64  linux.amd64  netbsd.amd64   openbsd.amd64  windows.amd64

You can add the appropriate directory to your path, alias the command, or copy it somewhere on your path, whatever is
convenient. For example:

    PATH=$PATH:$HOME/apache-brooklyn/bin/brooklyn-client-cli-0.9.0-SNAPSHOT/linux/amd64

## Documentation


{% include list-children.html %}