---
title: About Ansible
title_in_menu: About Ansible
layout: website-normal
---

## What you need to know about Ansible

[Ansible](http://docs.ansible.com/ansible/) is a deployment tool designed to work in an agent-less manner, normally 
performing its operations on a node over SSH from some central administrating node.  Brooklyn can deploy software 
via Ansible on one of its managed nodes, by first installing Ansible on the node itself and then using Ansible to deploy
the required software.

A 'Playbook' in Ansible is a specification of the configuration and deployment of a system. 
Playbooks are expressed in YAML format, and contain a number of 'plays', which are in turn lists of tasks to carry out
to achieve the desired configuration on the system.  'Roles' are pre-written modular collections of tasks, and can
be included in playbooks.

Ansible comes with built-in support for many software systems, and has a community repository of roles exists at 
[https://galaxy.ansible.com](https://galaxy.ansible.com).


### How Brooklyn interacts with Ansible

Brooklyn provides a Ansible entity type. An entity of this type can be specified in a blueprint in order to provision the 
node through Ansible. The Ansible entity will download Ansible and install it on the node. The entity type supports the 
configuration of Ansible playbooks to download, or write inline in the blueprint, for simple playbooks.
Configuration values for the playbooks can be supplied in the blueprint.  

Brooklyn will deploy the software specified in the playbook when the entity starts.  In addition, an effector is 
provided on the entity that supports general purpose Ansible instructions.



