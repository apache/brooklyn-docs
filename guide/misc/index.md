---
title: Other Resources
layout: website-normal
started-pdf-exclude: true
children:
- { title: Javadoc, path: javadoc/ }
- download.md
- release-notes.md
- known-issues.md
- { path: ../dev/, title_in_menu: "Developer Guide" }
- { path: /website/documentation/, title_in_menu: "All Documentation", menu_customization: { force_inactive: true } }
---

Further documentation specific to this version of Brooklyn includes:

{% for item in page.menu %}
* [{{ item.title_in_menu }}]({{ item.url }})
{% endfor %}

Also see the [other versions](/website/meta/versions.md) or [general documentation](/website/documentation).
