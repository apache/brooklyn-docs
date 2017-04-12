---
section: Site Structure
section_position: 1
section_type: inline
---

## Site Structure

The site structure and menus are built by a plug-in in `site_structure.rb`. This plug-in looks in the [YAML front matter](https://jekyllrb.com/docs/frontmatter/){:target="_blank"} 
for child pages to build the structure, and breadcrumbs to determine the parent pages to display. 

Child pages are a list of objects, stored in the field `children`. These are defined by string path to a file or a YAML 
object with a `path` to another file, or a `link` to an external URL. In addition a `title` can be defined 
for the text content of the HTML menu option. See the example below from 
[/guide/index.md](https://github.com/apache/brooklyn-docs/blob/master/guide/index.md){:target="_blank"}

{% highlight yaml %}
breadcrumbs:
- /website/documentation/index.md
- index.md
children:
- { path: /guide/start/index.md }
- { path: /guide/misc/download.md }
- { path: /guide/concepts/index.md }
- { path: /guide/blueprints/index.md }
- { path: /guide/java/index.md }
- { path: /guide/ops/index.md }
- { path: /guide/misc/index.md }
{% endhighlight %}
