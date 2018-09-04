---
section: Inline Children
section_position: 2
section_type: inline
---

### Inline Children

In addition to the `children` property defining lower pages in the site structure, they can also be used to define
inline sections within the current document. Inclusion in this way produces a menu link to an anchor in the current page.

Below is an example from [/guide/ops/persistence/index.md](https://github.com/apache/brooklyn-docs/blob/master/guide/ops/persistence/index.md){:target="_blank"}:

{% highlight yaml %}
children:
- { section: Command Line Options }
- { section: File-based Persistence }
- { section: Object Store Persistence }
- { section: Rebinding to State }
- { section: Writing Persistable Code }
- { section: Persisted State Backup }
{% endhighlight %}

Inline sections can also be detected from separate, child `.md` files. Including the tag `check_directory_for_children: true`
in the YAML front matter of a page causes the site structure plug-in to look through the current directory for any `.md` files
containing `section_type: inline` in the YAML front matter.

The content from these inline sections can then be included in the page content using the liquid tag `child_content`. This is shown below
in an example from [/guide/locations/index.md](https://github.com/apache/brooklyn-docs/blob/master/guide/locations/index.md){:target="_blank"}:

<pre>
---
title: Locations
layout: website-normal
check_directory_for_children: true
---

Locations are the environments to which Brooklyn deploys applications, including:

Brooklyn supports a wide range of locations:

* &lt;a href="#clouds"&gt;Clouds&lt;/a&gt;, where it will provision machines
* &lt;a href="#localhost"&gt;Localhost&lt;/a&gt; (e.g. your laptop), 
  where it will deploy via `ssh` to `localhost` for rapid testing
* &lt;a href="#byon"&gt;BYON&lt;/a&gt;, where you "bring your own nodes",
  specifying already-existing hosts to use
* And many others, including object stores and online services

Configuration can be set in `brooklyn.cfg`
or directly in YAML when specifying a location.
On some entities, config keys determining matching selection and provisioning behavior
can also be set in `provisioning.properties`.

{&#37; child_content &#37;}</pre>
