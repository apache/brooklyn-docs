---
title: Catalog Management
layout: website-normal
---

### Catalog Management

The Catalog module (from the tile on the homepage, or the module switch on the top right) in the web console will show all versions of catalog items,
and allow you to add new items.


#### Adding to the Catalog

There are three ways of adding items to the catalog from the UI.

1. **From the Catalog Module**: Click on the "Upload to catalog" button located on the top right corner then follow the
   instructions. Alternatively, you can directly drag and drop items on the screen. This will accept `*.bom`, `*.jar` and `*.zip` files.

2. **From the Blueprint Composer module**:
   If you have composed a blueprint on the fly in the Blueprint Composer, you can save it into the catalog by clicking on the
   "Add to catalog button" located on the bottom right on the screen. A modal will then be displayed which will ask you for the
   required metadata regarding this new item.

3. **From the Blueprint Importer module**:
   If you already have catalog items, you can paste them into the importer editor then click on the "Import button".
   This allows you to import any types of items, including locations.

In addition to the GUI, items can be added to the catalog via the REST API
with a `POST` of the YAML file to `/v1/catalog` endpoint.
To do this using `curl`:

~~~ bash
curl -u admin:password http://127.0.0.1:8081/v1/catalog --data-binary @/path/to/riak.catalog.bom
~~~ 

Or using the CLI:

~~~ bash
br catalog add /path/to/riak.catalog.bom
~~~ 



#### Deleting from the Catalog

On the UI, if you are viewing a bundle page, a "Delete" button can be used to delete it from the catalog.

Using the REST API, you can delete a versioned item from the catalog using the corresponding endpoint. 
For example, to delete the item with id `datastore` and version `1.0` with `curl`:

~~~ bash
curl -u admin:password -X DELETE http://127.0.0.1:8081/v1/catalog/applications/datastore/1.0
~~~ 


**Note:** Catalog items should not be deleted if there are running apps which were created using the same item. 
During rebinding the catalog item is used to reconstruct the entity.

If you have running apps which were created using the item you wish to delete, you should instead deprecate the catalog item.
Deprecated catalog items will not appear in the add application wizard, or in the catalog list but will still
be available to Brooklyn for rebinding. The option to display deprecated catalog items in the catalog list will be added
in a future release.

Deprecation applies to a specific version of a catalog item, so the full
id including the version number is passed to the REST API as follows:

~~~ bash
curl -u admin:password -X POST http://127.0.0.1:8081/v1/catalog/entities/MySQL:1.0/deprecated/true
~~~ 
