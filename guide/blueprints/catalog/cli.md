---
title: Brooklyn Server Command Line Arguments
layout: website-normal
---
# {{ page.title }}

### Brooklyn Server Command Line Arguments

The command line arguments when launching `brooklyn` include several commands for working with the catalog.

* `--catalogAdd <file.bom>` will add the catalog items in the `bom` file
* `--catalogReset` will reset the catalog to the initial state 
  (based on `brooklyn/default.catalog.bom` on the classpath, by default in a dist in the `conf/` directory)
* `--catalogInitial <file.bom>` will set the catalog items to use on first run,
  on a catalog reset, or if persistence is off

If `--catalogInitial` is not specified, the default initial catalog at `brooklyn/default.catalog.bom` will be used.
As `scanJavaAnnotations: true` is set in `default.catalog.bom`, Brooklyn will scan the classpath for catalog items,
which will be added to the catalog.
To launch Brooklyn without initializing the catalog, use `--catalogInitial classpath://brooklyn/empty.catalog.bom`

If [persistence](../../ops/persistence/) is enabled, catalog additions will remain between runs. If items that were
previously added based on items in `brooklyn/default.catalog.bom` or `--catalogInitial` are 
deleted, they will not be re-added on subsequent restarts of brooklyn. I.e. `--catalogInitial` is ignored
if persistence is enabled and persistent state has already been created.

For more information on these commands, run `brooklyn help launch`.


<!--
TODO: make test cases from the code snippets here, and when building the docs assert that they match test cases
-->