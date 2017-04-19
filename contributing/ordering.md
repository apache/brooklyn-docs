---
section: Child Page Ordering
section_position: 3
section_type: inline
---

### Child Page Ordering

Child pages are by default, ordered by their position in the `children` YAML front matter field. This can be changed using the property
`section_position` in the child YAML. For children defined in the front matter this is put in the child object of the `children` array.

For inline children, sourced using `check_directory_for_children: true`, this `section_position` property is put in the child file's YAML front matter.

The format for `section_position` is that of software versioning, i.e `A.B... Z` where A, B etc are numbers of decreasing value. Position `1.1.0` would appear
before version `1.0.4` for example. This allows an infinite number of sub pages between each `section_position`.

Any un-versioned pages are automatically numbered to add a new minor version from the last page if that was numbered or increment the minor
if it was not. If no pages are yet numbered, the numbering is started at `1.1`. For example, if a numbered page, `1.4` is followed by a 
non-numbered page, the non-numbered page would be auto-numbered as `1.4.1`. If this page is followed by another non-numbered page it would
be auto-numbered as `1.4.2`.

For example, a set of children pages numbered like this:

{% highlight yaml %}
children:
- { path: /guide/start/index.md, section_position: 3.1.2 }
- { path: /guide/misc/download.md }
- { path: /guide/concepts/index.md }
- { path: /guide/blueprints/index.md }
- { path: /guide/blueprints/java/index.md }
- { path: /guide/ops/index.md, section_position: 2 }
- { path: /guide/misc/index.md }
{% endhighlight %}

Would end up numbered like this:

{% highlight yaml %}
children:
- { path: /guide/ops/index.md, section_position: 2 }
- { path: /guide/misc/index.md, section_position: 2.1 }
- { path: /guide/start/index.md, section_position: 3.1.2 }
- { path: /guide/misc/download.md, section_position: 3.1.2.1 }
- { path: /guide/concepts/index.md, section_position: 3.1.2.2 }
- { path: /guide/yaml/index.md, section_position: 3.1.2.3 }
- { path: /guide/java/index.md, section_position: 3.1.2.4 }
{% endhighlight %}

This ordering affects both the position of the child in the html menu and the order of content included with `child_content`.
