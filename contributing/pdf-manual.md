---
section: Single Page Manual and PDF
section_position: 4
section_type: inline
---

## Single Page Manual and PDF

A single page overview of selections of the site are available in `zoneMergeManual` and `zoneMergeStarted`. These overviews are for the user manual
and getting started guide respectively. The zone merge pages go through the [site structure](index.html#site-structure), described above, and compile the files from this into a
single HTML page.

In order to do this, each page is iterated over in order and it's rendered content included in the page. The plug-in `regex_filter.rb` is used to re-write
 &lt;a&gt; links from the structured site into a form which works on a single page. Links are re-written in the following manner:

- If the link is from an external domain, leave it as an unaltered link
- If the link is an anchor, convert to the anchor scheme used in the single page
- If the link target is in the single page, change the link to point at the anchor in the single page
- If the link is pointing at somewhere on the brooklyn site which is not included in this single page, point to the website with a specific version, so https://brooklyn.apache.org/v/0.9.0-SNAPSHOT/start/concept-quickstart.html for instance

In addition, all images src's are re-written relative to the root directory.

Pages can be masked from the compilation process by defining a `page_mask` in the YAML front matter of the zone merge file, then including this mask as `true` in the child page to exclude.
These pages will then not be included in the compiled single page. Note that this will mask both the child page and any children of this masked page. 
For example [zoneMergeStarted](https://github.com/apache/brooklyn-docs/blob/master/zoneMergeStarted.html){:target="_blank"} uses the mask `started-pdf-exclude`:
 
{% highlight yaml %}
title: Apache Brooklyn Manual
layout: singlePage
page_mask: started-pdf-exclude
...
{% endhighlight %}

Then in latter pages, such as [/guide/ops/index.md](https://github.com/apache/brooklyn-docs/blob/master/guide/ops/index.md){:target="_blank"} include `started-pdf-exclude: true` to
exclude this section from the getting started guide.

{% highlight yaml %}
title: Operations
started-pdf-exclude: true
...
{% endhighlight %}

This will exclude not only the operations page but all of the operations section.

Specific content can be also be masked or unmasked at a page component level by specifying CSS show and hide classes:

{% highlight yaml %}
css_hide_class: usermanual-pdf-exclude
css_show_class: usermanual-pdf-include
{% endhighlight %}

If the above YAML is included in the front matter of a zone merge file, the classes `usermanual-pdf-exclude` and `usermanual-pdf-include` will add or remove a
`display: none` to a HTML object. In addition the single page theme files [singlePage.html](https://github.com/apache/brooklyn-docs/blob/master/_layouts/singlePage.html){:target="_blank"} and
[singlePage.css](https://github.com/apache/brooklyn-docs/blob/master/style/css/singlePage.css) can be used to style only the single merged pages.

### Conversion to PDF

These single merged pages are then converted to PDF using wkhtmltopdf in the build scripts of this site.
