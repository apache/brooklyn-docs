---
title: Workflow
partial-summary-depth: 1
layout: website-normal
children:
- defining.md
- common.md
- steps.md
- variables.md
- nested-workflow.md
---

Apache Brooklyn has a powerful workflow engine and syntax for defining entities, effectors, sensors, and policies.

For example, to define an effector `one-and-two` which invokes effector `one` then effector `two`, you can write:

```yaml
brooklyn.initializers:
  - type: workflow-effector
    name: one-and-two
    steps:
      - invoke-effector one
      - invoke-effector two
```

This can be used within [most Apache Brooklyn resources](defining.md).

The syntax supports [longhand, conditions, loops, error-handling](common.md), [variables](variables.md),
a large set of [built-in step types](steps.md), and the ability to [define custom step types](nested-workflow.md).

You can also get started by looking at examples:

* [Ansible/BASH for a web server](example-ansible-and-bash.yaml)
* [OAuth web request workflow](oauth.yaml)
