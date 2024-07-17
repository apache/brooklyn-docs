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

Apache Brooklyn workflow supports a range of step types covering the most common activities
commonly done as part of application management.
These are divided into the following groups:

* [Workflow Control](#workflow-control): use local variables and control flow,
  with step types such as `let`, `return`, and `retry`
* [External Actions](#external-actions): interact with external systems 
  using step types such as `container`, `ssh`, `winrm`, and `http`
* [Application Models](#application-models): work with the models stored in Brooklyn,
  doing things such as `invoke-effector`, `set-sensor`, `deploy-application`, and `add-entity`
* [General Purpose](#general-purpose): miscellaneous step types such as `log` and `sleep`

Custom step types can be written and added to the catalog, either written as workflow using these primitives
(including doing virtually anything in a container) or by implementing a Java type, both [as described here](../nested-workflow.md).
An index of all out-of-the-box step types is included at the [end of this section](#index-of-step-types).


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
