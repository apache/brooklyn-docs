---
title: Tips and Tricks
layout: website-normal
---

## Filtering Lists

There are many `transform` filters available, but none will filter lists.
Removing elements from a list is easily be done by using `foreach`` with a `condition`,
returning elements that meet the condition.

For example, to filter out non-empty strings from a list:

```
- let list_to_filter = [ "word1", "", "word2" ]
- step: foreach item in ${list_to_filter}
  condition:
    size: { greater-than: 0 }
  steps:
  - return ${item} 
```

The output from the `foreach` step is the list of results,
so this results in the filtered list `["word1", "word2"]`.

(This condition uses `size` to find the length of the string.
The `condition: { not: { equals: "" } }` could just as well be used,
or using the fact that `equals` can be made implicit, simply
`condition: { not: "" }`.)

Here is a more complicated example which filters comma-separated words
to return known fruits and proper names:

```
- let requested_foods = "apple, banana, Nutella, invalid"
- transform value ${requested_foods} | split regex \S*,\S* | trim
- let list known_fruits = [ "apple", "orange", "banana" ]
- step: foreach item in ${output}
  condition:
    any: 
    - regex: [A-Z].*               # match proper name
    - target: ${known_fruits}      # match known fruits
      contains: ${item}
  steps:
  - return ${item}
```

The above will return the list of `apple`, `banana`, and `Nutella`, dropping `invalid`.



## Optimizing for Workflows

Workflows can generate a huge amount of data which can impact memory usage, persistence, and the UI.
The REST API and UI do some filtering (e.g. in the body of the `internal` sensors used by workflow),
but when working with large `ssh` `output` and `http` `content` payloads, and with `update-children`,
performance can be dramatically improved by following these tips:

* Optimize external calls to return the minimal amount of information needed
  * Use `jq` to filter when using `ssh` or `container` steps
  * Pass filter arguments to `http` endpoints that accept them
  * Loop over small page sizes (e.g. 20 records per cycle from `http`) using `retry from` steps

* Optimize the data which is stored
  * Override the `output` on `ssh` and `http` steps to remove unnecessary objects;
    for example `http` returns several `content*` fields, and often just one is needed.
    Simply settings `output: { content: ${content} }` will achieve this.
  * Set `retention: 1` or `retention: 0` on workflows that use a large amount of information
    and can simply be replayed from the start; additionally `retention: disabled` can be used
    to prevent any persistence (even for ongoing workflows), but only for workflows that do
    not acquire any `lock`

