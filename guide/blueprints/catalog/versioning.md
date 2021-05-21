---
title: Versioning
layout: website-normal
---

Brooklyn supports multiple versions of a type to be installed and used at the same time.
Versions are a first-class concept and are often prominently displayed in the UI.

In order to do this, Brooklyn requires that the `id:version` string be unique across the catalog:
it is normally an error to add a type if a type with the same `id:version` is present.
The exceptions to this are if the definition is identical, or if the `version` is noted as a `SNAPSHOT`.
In extraordinary circumstances it may be appropriate to delete a given `id:version` definition
and then add the new one, but this is discouraged and the usual practice is to:

* Use a `-SNAPSHOT` qualifer suffix on your version when developing
* Increase the version number when making a change to a non-SNAPSHOT type  

When adding to the catalog, if no version is supplied, Brooklyn will typically use 
`0.0.0-SNAPSHOT`, and some clients will automatically create and increment the version number 
for the catalog item.

When deploying a blueprint, if a version number is not specified Brooklyn will typically use
the highest ordered version (see "Ordering" below) in the catalog for the referenced type,
and will thereafter lock the use of that version in that blueprint.
(An exception is where types are co-bundled or an explicit search path is defined;
in the context of evaluating one type, Brooklyn may prefer versions in the same bundle 
or on the search path.)


#### Versioning Syntax

Version numbers in Brooklyn are recommended to follow the following syntax:

~~~
<major> ( "." <minor> ( "." <patch> )? )? ( "-" <qualifier> )?
~~~

where the `<major>`, `<minor>`, and `<patch>` parts are numbers
in accordance with [semver](http://semver.org) semantic versioning,
assumed to be `0` if omitted,
and an `<qualifier>` is made up of letters, numbers, `"-"` and `"_"`
in accordance with [OSGi](https://www.osgi.org/release-4-version-4-3-download/)
(see sections 1.3.2 and 3.2.5).

Examples:

* `1.2`
* `2.0.0`
* `3`
* `2.0.0-SNAPSHOT`
* `1.10-rc3-20170619`


#### Snapshots and Ordering

The string `SNAPSHOT` appearing anywhere in the version indicates a pre-release version;
if this string is not present the version is treated as a release version.

When taking an ordering, for instance to find the highest version, 
snapshot versions are always considered lower than release versions.
Next, the natural order is taken on the major, minor, and patch fields.
Next, a version with no qualifier is considered higher than one with a qualifier.
Finally, the qualifier is taken in natural order.

The natural order here is defined as 
numeric order for digit sequences (`"9" < "10"`)
and ASCII-lexicographic comparison elsewhere (`"a" < "b"`),
which is normally what people will expect for versions 
(`1.9` < `1.10` and `"1.1-rc9-b" < "1.1-rc10-a"`).

Thus the _order_ of the list of examples above is:

* `2.0.0-SNAPSHOT`
* `1.2`
* `1.10-rc3-20170619`
* `2.0.0`
* `3`

For most practical purposes, `3`, `3.0`, and `3.0.0` are treated as equivalent,
but if referencing a version you should use the exact version string defined.
The version `3.0-0` is different, as the `-0` indicates a qualifier, and
is ordered before a `3.0.0`.
 

#### Advanced: Other Version Syntaxes

Other version syntaxes are supported with the following restrictions:

* Version strings MUST NOT contain a colon character (`:`)
* Version strings MUST NOT be empty
* Fragments that do not follow the recommended syntax may be ignored
  when determining version uniqueness
  (e.g. adding both `"1.0.0-v1.1"` and "1.0.0-v1_1" can result in 
  one bundle _replacing_ the other rather than both versions being loaded) 

This means in practice that almost any common version scheme can be used.
However the recommended scheme will fit more neatly alongside types from other sources.

Internally when installing bundles, Brooklyn needs to produce OSGi-compliant versions.
For the recommended syntax, this mapping consists of replacing the first
occurrence of `"-"` with `"."` and setting `0` values for absent minor and patch versions.
Thus when looking at the OSGi view, instead of version `1.10-rc3-20170619`
you will see `1.10.0.rc3-20170619`.
Apart from the omission of `0` as minor and patch versions,
this mapping is guaranteed to be one-to-one so no conflicts will occur if the
recommended syntax is used.
Bundles `foo:3`, `foo:3.0`, and `foo:3.0.0` would all be installed using OSGi version `3.0.0`,
and so would conflict and block installation if there is any change
(and replace if they have a `-SNAPSHOT` qualifier);
references to bundles can use `3` or `3.0` or `3.0.0`, though as noted above 
types contained within would have to be referenced using the exact version string supplied. 
(If different versions are specified on individual types than for the bundle itself --
which is not recommended -- then the conversion to OSGi does not apply, 
and the versions are not treated as equal;
in such edge cases the ordering obeys numeric then ASCII ordering on segments,
so we have `3` < `3.0` < `3.01` < `3.1` < `3.09` < `3.9` < `3.10` 
and `v-1` < `v.1` < `v_1`.)
            
If not using the recommended syntax, the mapping proceeds by treating the first dot-separated fragment 
as the qualifer and converts unsupported characters in a qualifier to an underscore;
thus `1.x` becomes `1.0.0.x`, `v1` becomes `0.0.0.v1`, and `"1.0.0-v1.1"` becomes `"1.0.0.v1_1"` 
hence the bundle replacement noted above.

If you are creating an OSGi `MANIFEST.MF` for a bundle that also contains a `catalog.bom`, 
you will need to use the mapped result (OSGi version syntax) in the manifest,
but should continue to use the Brooklyn-recommended syntax in the `catalog.bom`.
 
For those who are curious, the reason for the Brooklyn version syntax is to reconcile
the popular usage of semver and maven with the internal requirement to use OSGi versions.
Semver, OSGi, and maven conventions agree on up to three numeric dot-separated tokens,
but differ quite significantly afterwards, with Brooklyn adopting what seems to be the
most popular choices in each.

A summary of the main differences between Brooklyn and other versioning syntaxes is as follows: 

* Qualifier preceded by hyphen (maven and semver semantics, different to OSGi which wants a dot)
* Underscores allowed in qualifiers (OSGi and maven semantics, different to semver)
* Periods and plus not allowed in qualifiers (OSGi semantics and maven convention, 
  different to semver which gives them special meaning)
* The ordering used in Brooklyn is different to that used in OSGi
  (where qualifiers come after the unqualified version and don't do a numeric comparison)
* `SNAPSHOT` treated specially (maven semantics)
* Maven's internal to-OSGi conversion is different for some non-recommended syntax strings
  (e.g. `10rc1` becomes `10.0.0.rc1` in Brooklyn but Maven will map it by default to `0.0.0.10rc1`)  


