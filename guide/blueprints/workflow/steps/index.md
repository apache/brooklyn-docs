---
title: Workflow Steps
layout: website-normal
children:
- { section: Workflow Control }
- { section: External Actions }
- { section: Application Models }
- { section: General Purpose }
- { section: Index of Step Types }
---

{% jsonball steps from yaml file steps.yaml %}
{% assign step_summaries = "" | split: ", " %}

{% for x in steps %}

{% assign step_summaries = step_summaries | concat: x.steps %}

## {{ x.section_name }}

{{ x.section_intro }}


<div class="no-space-in-list" markdown="1" style="margin-top: 0; margin-bottom: 42px;">
  {% for step in x.steps %}
* [`{{ step.name }}`](#{{ step.name }})
  {% endfor %}

</div>


  {% for step in x.steps %}

### `{{ step.name }}`

{{ step.summary }}

{% if step.shorthand %}
**Shorthand**: {{ step.shorthand }}
{% endif %}

{% if step.input %}
**Input parameters**:
{{ step.input }}
{% endif %}

{% if step.output %}
**Output return value**:
{{ step.output }}
{% endif %}

<div style="margin-bottom: 42px;"></div>

  {% endfor %}

{% endfor %}



## Index of Step Types

{% assign step_summaries = step_summaries | sort: "name" %}

<div class="no-space-in-list" markdown="1" style="margin-top: 0; margin-bottom: 42px;">
{% for x in step_summaries %}

* [{% if x.shorthand %}`{{ x.name }}`{% else %}`{{ x.name }}`{% endif %}](#{{ x.name }})

{% endfor %}
</div>
