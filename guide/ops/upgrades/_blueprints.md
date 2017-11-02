
## Upgrading Blueprints and Bundles

You can install and deploy new versions of blueprints at any time.
Brooklyn tracks multiple versions of the blueprints you install, as can be seen in the catalog.


### Defining and Forcing Upgrade Paths

Bundles can declare what bundles and types they can upgrade,
and they can also force the removal of installed bundles and types on startup/rebind.
Forcing can be useful when upgrading Brooklyn to replace any installed bundle
not compatible with the newer version of Brooklyn.

To add these definitions, use the following headers in the bundle's OSGi `META-INF/MANIFEST.MF`:

* `brooklyn-catalog-force-remove-bundles`
* `brooklyn-catalog-force-remove-legacy-items`
* `brooklyn-catalog-upgrade-for-bundles`
* `brooklyn-catalog-upgrade-for-types`

The most common patterns are to indicate that a bundle can replace all previous versions of itself
and all types thereing with types in the current bundle of the same name, using:

```
brooklyn-catalog-upgrade-for-bundles: *
```

And you can indicate that previous bundles should be uninstalled, forcing the above upgrades,
with:

```
brooklyn-catalog-force-remove-bundles: *
```

The above items can also take a range syntax, e.g. `"*:[1,2)"` when releasing a `2.0.0` to restrict to
versions equal to or greater than `1.0.0` but less than `2.0.0`. (Note that ranges must be quoted.)
Entries can also take comma-separated lists, and in the case of replacements, they can define
explicit renamed targets using `sourceNameAndVersionRanges=targetNameAndVersion` entries.   
These fields are defined in full in the
[`BundleUpgradeParser`'s javadoc]({{book.url.brooklyn_javadoc}}/org/apache/brooklyn/core/typereg/BundleUpgradeParser.html).


### Upgrading the Version of Deployed Blueprints

New versions of blueprints are not automatically applied to existing deployments from
older versions. This requires a rebind using the above techniques, or programmatic intervention:
please ask on the mailing list for more information
(and to help us identify the most common wishes in this area!).

