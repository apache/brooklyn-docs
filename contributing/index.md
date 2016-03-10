---
layout: website-normal
title: Contributing to the Docs
check_directory_for_children: true
---

The Apache Brooklyn documentation is written in [kramdown](http://kramdown.gettalong.org/syntax.html){:target="_blank"} a superset of Markdown 
which is processed into HTML using [Jekyll](https://jekyllrb.com/){:target="_blank"}. In addition to the standard set of options
and notation available with these platforms, a number of custom plug-ins have been implemented specifically
for the Apache Brooklyn docs. These are detailed below:

Jekyll plug-ins are written in ruby and kept in the `_plugins` folder. Note that if you're using `jekyll serve` to
display the site, changes to these plug-ins will not be reflected in the rendered site until jekyll is restarted. 

{% child_content %}
