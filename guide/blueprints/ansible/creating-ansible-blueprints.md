---
title: Creating Blueprints with Ansible
title_in_menu: Creating Blueprints with Ansible
layout: website-normal
---
# {{ page.title }}

To write a blueprint to use Ansible with Brooklyn it will help to have a degree of familiarity with Ansible itself. In the 
sections below, when the Brooklyn configuration is described, the underlying Ansible operation is also noted briefly, for 
clarity for readers who know Ansible.

To manage a node with Ansible, create a blueprint containing a service of type `org.apache.brooklyn.entity.cm.ansible.AnsibleEntity`
and define and minimum the `playbook` value, and one or other of `playbook.url` or `playbook.yaml`. You must also define
the `service.name` that will be tested in order to determine if the entity is running successfully.

For example:

    name: myweb
    location: ...
    services:
      - type: org.apache.brooklyn.entity.cm.ansible.AnsibleEntity
        id: apache
        name: apache
        service.name: apache2
        playbook: apache-playbook
        playbook.url: http://myhost/projectX/apache-playbook.yaml

    
This example specifies that Brooklyn should use Ansible to download the playbook from the repository on
"myhost". The playbook contains the instructions to install the Apache web server. To start the 
entity, Brooklyn will use Ansible's "ansible-playbook" command to run the playbook, which will bring up the web server.


### Lifecycle of AnsibleEntity

The start effector applies the playbook and verifies that it has started the software correctly by checking the service
defined as `service.name` is running.  This can be customized, see `ansible.service.start` configuration below.

The stop effector will stop the service `service.name`.  Again, this can be customized, with `ansible.service.stop`. 

The restart effector will apply stop and then start.


### Configuration of AnsibleEntity

The `playbook` configuration key names the top level list of states that will be applied using Ansible.  
 This configuration key is mandatory.

The playbook must be defined using one or other (both together are not permitted) of  `playbook.yaml` or `playbook.url`.
The former allows the playbook content to be defined inline within the blueprint, using the normal YAML format of an 
Ansible playbook.  The latter obtains the playbook from an external URL.

The `ansible.service.start` configuration key allows the blueprint author to override the command used by default to 
verify that the service `service.name` is running (or to start it, if the playbook did not specify it should run by
default).  The default value is:

    sudo ansible localhost -c local -m service -a "name=<service.name> state=started"

Similarly the `ansible.service.stop` configuration key permits override of the instruction used to get Ansible to stop the
service, by default

    sudo ansible localhost -c local -m service -a "name=<service.name> state=stopped"

The `ansible.service.checkPort` configuration key allows the user to override the mechanism used to check that the 
service `service.name` is operating. By default Brooklyn checks that the service process is running. However, if the
 service is one that listens on a particular port, this configuration key allows the blueprint author to instruct
 Brooklyn to check that the port is being listened on, using the Ansible `wait_for` module. The value of the key is 
 the port number to check.

The `ansible.vars` configuration key allows the blueprint author to provide entity-specific values for configuration
variables used in the playbook, so that one playbook can be used by multiple entities, each customized appropriately.
The value of `ansible.vars` is an arbitrary block of YAML configuration that will be applied to the playbook using 
Ansible's `--extra-vars` mechanism, as described in the
Ansible [documentation](http://docs.ansible.com/ansible/playbooks_variables.html#passing-variables-on-the-command-line).
For example, if the playbook in the example above contained configuration such as:
 
    - hosts: all
      vars:
        http_port: 80
        max_clients: 200
      remote_user: root
      tasks:
      ...
 
 then to change the port that the webserver in the example above runs on, it would be possible to define the following 
 in the blueprint:
 
    name: myweb
    location: ...
    services:
      - type: org.apache.brooklyn.entity.cm.ansible.AnsibleEntity
        id: apache
        name: apache
        service.name: apache2
        playbook: apache-playbook
        playbook.url: http://myhost/projectX/apache-playbook.yaml
        ansible.vars:
            http_port: 8080


### ansibleCall Effector

The Ansible entity includes a general purpose Ansible effector, `ansibleCommand`, which permits execution of Ansible 
commands via `ansible`.  It contains a two parameters:
1. `module` specifies the Ansible module to invoke.  The default is "command".
2. `args` specifies the argument data for the Ansible module.  For example, to download an additional file for the 
webserver, the command could be invoked with the following arguments. (For convenience this
example uses the client CLI, "br", but the effector could be invoked by any applicable means, e.g. via the web UI 
or REST API.)

    $ br app myweb ent apache effector ansibleCommand invoke \
       -P module=shell -P args='curl http://myhost:8080/additional.html > /var/www/html/additional.html'

### Roles and Multi-Playbook Installations

There is no specific configuration in AnsibleEntity for Ansible [Roles](http://docs.ansible.com/ansible/playbooks_roles.html),
 or to install multiple playbooks. However, the installation of roles or multiple playbooks can be carried out first 
 by taking advantage of Brooklyn's SameServerEntity. The installation step can be applied in one child of the same server
 entity, while the AnsibleEntity can operate under the second child. It will typically be necessary to delay the start
 of the AnsibleEntity until the first child has carried out whatever preparation is required. The examples below
 illustrate the concept (with just one playbook, for brevity).
 
 One way to a achieve this, as with any Brooklyn entity, is to use the idiom of making it a child of a BasicApplication 
 with a start latch waiting on the first child, such as in the following example, which installs the standalone Tomcat example,
 with its playbook and roles, from the "Ansible Examples" Github site. 
 (Note, this is designed for installation on Redhat/Centos 6.)
 The first child in the SameServerEntity downloads
 and unpacks the Ansible examples. This might also install standalone Ansible roles, or whatever other resources the
 AnsibleEntity might require.  The second child uses `attributeWhenReady` to block until the first is ready, before 
 starting the AnsibleEntity to apply the desired playbook.
 

    name: multi
    location:
      red1
    services:
    - serviceType: brooklyn.entity.basic.SameServerEntity
      name: Entities
      brooklyn.children:
      
      - serviceType: org.apache.brooklyn.entity.cm.ansible.AnsibleEntity
        id: bootstrap
        service.name: crond
        playbook: bootstrap
        playbook.yaml: |
            ---
            - hosts: localhost
              tasks:
              - shell: printf "[tomcat-servers]\nlocalhost ansible_connection=local\n" >> /etc/ansible/hosts
              - file: path=/etc/ansible/playbooks state=directory mode=0755
              - get_url: url=https://github.com/ansible/ansible-examples/archive/master.zip dest=/tmp/master.zip mode=0440
              - command: unzip -o -d /etc/ansible/playbooks /tmp/master.zip
    
      - serviceType: org.apache.brooklyn.entity.stock.BasicApplication
        latch.start: $brooklyn:entity("bootstrap").attributeWhenReady("service.isUp")
        brooklyn.children:
        - type: org.apache.brooklyn.entity.cm.ansible.AnsibleEntity
          name: test
          service.name: tomcat
          playbook: tomcat
          playbook.yaml: |
              ---
              - hosts: localhost
              - include: /etc/ansible/playbooks/ansible-examples-master/tomcat-standalone/site.yml
                vars:
                    http_port: 8080
                    https_port: 8443
                    admin_username: admin
                    admin_password: secret

 
An alternative to the above is to use Ansible itself to do the waiting, as in the variant below, which uses AnsibleEntity
itself in the first SameServerEntity child, to install the required material.  In the second child, which is simply an
AnsibleEntity rather than a BasicApplication, Ansible's `wait_for` operation is used as the first step in the playbook, 
to block the remaining steps in its playbook until the first is complete.

    name: multi
    location:
      red1
    services:
    - serviceType: brooklyn.entity.basic.SameServerEntity
      name: Entities
      brooklyn.children:
      
      - serviceType: org.apache.brooklyn.entity.cm.ansible.AnsibleEntity
        id: bootstrap
        service.name: crond
        playbook: bootstrap
        playbook.yaml: |
            ---
            - hosts: localhost
              tasks:
              - command: rm -f /tmp/bootstrap.done
              - shell: printf "[tomcat-servers]\nlocalhost ansible_connection=local\n" >> /etc/ansible/hosts
              - file: path=/etc/ansible/playbooks state=directory mode=0755
              - get_url: url=https://github.com/ansible/ansible-examples/archive/master.zip dest=/tmp/master.zip mode=0440
              - command: unzip -o -d /etc/ansible/playbooks /tmp/master.zip
              - file: path=/tmp/bootstrap.done state=touch
    
      - serviceType: org.apache.brooklyn.entity.cm.ansible.AnsibleEntity
        name: test
        service.name: tomcat
        playbook: tomcat
        playbook.yaml: |
            ---
            - tasks:
              - wait_for: path=/tmp/bootstrap.done
              include: /etc/ansible/playbooks/ansible-examples-master/tomcat-standalone/site.yml
              vars:
                http_port: 8080
                https_port: 8443
                admin_username: admin
                admin_password: secret

