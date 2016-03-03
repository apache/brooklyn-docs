---
title: Locations
layout: website-normal
check_directory_for_children: true
---

Locations are the environments to which Brooklyn deploys applications, including:

Brooklyn supports a wide range of locations:

* <a href="#clouds">Clouds</a>, where it will provision machines
* <a href="#localhost">Localhost</a> (e.g. your laptop), 
  where it will deploy via `ssh` to `localhost` for rapid testing
* <a href="#byon">BYON</a>, where you "bring your own nodes",
  specifying already-existing hosts to use
* And many others, including object stores and online services

Configuration can be set in `~/.brooklyn/brooklyn.properties`
or directly in YAML when specifying a location.
On some entities, config keys determining maching selection and provisioning behavior
can also be set `in `provisioning.properties`.  

{% child_content %}
