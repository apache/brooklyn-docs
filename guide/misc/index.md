---
title: Other Resources
partial-summary-depth: 1
---

{% if output.name == 'website' %}
Further documentation specific to this version of Brooklyn includes:

{% for item in page.menu %}
* [{{ item.title_in_menu }}]({{ item.url }})
{% endfor %}

Also see the [other versions]({{ book.url.brooklyn_website }}/meta/versions.html) or [general documentation]({{ book.url.brooklyn_website }}/documentation/).
{% endif %}