---
title: Other Resources
children:
- { title: Javadoc, path: javadoc/ }
- download.md
- release-notes.md
- known-issues.md
- { path: ../dev/, title_in_menu: "Developer Guide" }
- { path: /website/documentation/, title_in_menu: "All Documentation", menu_customization: { force_inactive: true } }
---

{% if output.name == 'website' %}
Further documentation specific to this version of Brooklyn includes:

{% for item in page.menu %}
* [{{ item.title_in_menu }}]({{ item.url }})
{% endfor %}

Also see the [other versions]({{ book.url.brooklyn_website }}/meta/versions.html) or [general documentation]({{ book.url.brooklyn_website }}/documentation/).
{% endif %}