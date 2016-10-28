---
title: Machine Location Customizers
layout: website-normal
check_directory_for_children: true
---

* [org.apache.brooklyn.entity.machine.SetHostnameCustomizer](https://github.com/apache/brooklyn-server/blob/master/software/base/src/main/java/org/apache/brooklyn/entity/machine/SetHostnameCustomizer.java)
Sets the hostname on an ssh'able machine. Currently only CentOS and RHEL are supported.
The customizer can be configured with a hard-coded hostname, or with a freemarker template whose value (after substitutions) will be used for the hostname.
