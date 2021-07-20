---
title: Policies
partial-summary-depth: 1
layout: website-normal
children:
- available_policies.md
- writing_policies.md
---

Policies perform the active management enabled by Brooklyn.
They can subscribe to entity sensors and be triggered by them (or they can run periodically,
or be triggered by external systems).

Policies can add subscriptions to sensors on any entity. Normally a policy will subscribe to sensors on
either its associated entity, that entity's children and/or to the members of a "group" entity.

Common uses of a policy include the following:

* perform calculations,
* look up other values,
* invoke effectors  (management policies) or,
* cause the entity associated with the policy to emit sensor values (enricher policies).

Entities can have zero or more `Policy` instances attached to them.

{% include list-children.html %}

