---
title: Catalog
partial-summary-depth: 1
---

Apache Brooklyn provides a **catalog**, which is a persisted collection of versioned blueprints 
and other resources. A set of blueprints is loaded from the `default.catalog.bom` in the Brooklyn 
folder by default and additional ones can be added through the web console or CLI.  Blueprints in 
the catalog can be deployed directly, via the Brooklyn CLI or the web console, or referenced in 
other blueprints using their `id`.


