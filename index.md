---
layout: website-landing
title: Home
children:
- learnmore/

- link: /v/latest/start/index.html
  title_in_menu: Get Started
  href_link: /v/latest/start/index.md
  menu:
  - link: /v/latest/start/running.html
    title_in_menu: "Running Apache Brooklyn"
    not_external: true

  - link: /v/latest/start/blueprints.html
    title_in_menu: "Deploying Blueprints"
    not_external: true

  - link: /v/latest/start/managing.html
    title_in_menu: "Monitoring and Managing Applications"
    not_external: true

  - link: /v/latest/start/policies.html
    title_in_menu: "Policies"
    not_external: true

  - link: /v/latest/start/concept-quickstart.html
    title_in_menu: "Brooklyn Concepts Quickstart"
    not_external: true

- path: documentation/
  menu:

  - link: /v/latest/index.html
    title_in_menu: "User Guide"
    menu_customization: { dropdown_section_header: true }
    not_external: true

  - link: /v/latest/blueprints/creating-yaml.html
    title_in_menu: Writing Blueprints
    not_external: true

  - link: /v/latest/locations/index.html
    title_in_menu: Deploying Blueprints
    not_external: true

  - link: /v/latest/ops/index.html
    title_in_menu: Reference Guide
    menu_customization: { dropdown_section_header: true }
    not_external: true

  - link: /v/latest/dev/index.html
    title_in_menu: Developer Guide
    not_external: true

  - path: meta/versions.md
    title_in_menu: Versions
    menu_customization: { dropdown_new_section: true }

  - path: documentation/other-docs.md
    title_in_menu: Other Resources

- community/

- developers/

- path: download/
  menu: null
  type: button
  menu_customization: {type: button}
---

<section class="text-center hero" markdown="1">

# <span class="text-apache">apache</span> <span class="text-brooklyn">brooklyn</span>

## Your applications, any clouds, any containers, anywhere.
 
<a href="#get-started" class="btn btn-primary btn-lg">Get started</a>
<a href="https://github.com/apache/brooklyn" class="btn btn-link btn-lg"><i class="fa fa-fw fa-github"></i> View code</a>

</section>

<section class="container about">
<h3 class="text-center">Use Apache brooklyn for &hellip;</h3>
<div class="row">

<div class="col-md-4" markdown="1">
<p>
<span class="fa-stack fa-2x">
<i class="fa fa-circle-thin fa-stack-2x "></i>
<i class="fa fa-archive fa-stack-1x modeling"></i>
</span>
</p>

#### Modeling

*Blueprints* describe your application, stored as *text files* in *version control*

*Compose* from the [*dozens* of supported components](learnmore/catalog/) or your *own components* using *bash, Java, Chef...*

<div class="text-muted" markdown="1">
#### JBoss &bull; Cassandra &bull; QPid &bull; nginx &bull; [many more](learnmore/catalog/)
</div>
</div>

<div class="col-md-4" markdown="1">
<p>
<span class="fa-stack fa-2x">
<i class="fa fa-circle-thin fa-stack-2x "></i>
<i class="fa fa-rocket fa-stack-1x deploying"></i>
</span>
</p>

#### Deploying

Components *configured &amp; integrated* across *multiple machines* automatically

*20+ public clouds*, or your *private cloud* or bare servers - and *Docker* containers

<div class="text-muted" markdown="1">
#### Amazon EC2 &bull; CloudStack &bull; OpenStack &bull; SoftLayer &bull; many more
</div>
</div>

<div class="col-md-4" markdown="1">
<p>
<span class="fa-stack fa-2x">
<i class="fa fa-circle-thin fa-stack-2x "></i>
<i class="fa fa-cog fa-stack-1x managing"></i>
</span>
</p>

#### Managing

*Monitor* key application *metrics*; *scale* to meet demand; *restart* and *replace* failed components

View and modify using the *web console* or automate using the *REST API*

<div class="text-muted" markdown="1">
#### Metric-based autoscaler &bull; Restarter &amp; replacer &bull; Follow the sun &bull; Load balancing 
</div>

</div>
</div>
</section>


<section class="jumbotron get-started" id="get-started">
  <div class="container">
    <div class="row">
      <div class="col-md-12">
        <h3 class="text-center">Get started</h3>
        <div class="shell">
          <div class="shell-toolbar">
            <i class="red"></i>
            <i class="yellow"></i>
            <i class="green"></i>
            <span>bash</span>
          </div>
{% highlight bash %}
curl -SL --output apache-brooklyn-{{site.brooklyn-stable-version}}-vagrant.tar.gz "https://www.apache.org/dyn/closer.lua?action=download&filename=brooklyn/apache-brooklyn-{{site.brooklyn-stable-version}}/apache-brooklyn-{{site.brooklyn-stable-version}}-vagrant.tar.gz"
tar xvf apache-brooklyn-{{site.brooklyn-stable-version}}-vagrant.tar.gz
cd apache-brooklyn-{{site.brooklyn-stable-version}}-vagrant
vagrant up brooklyn
{% endhighlight %}
        </div>
        <div class="text-muted row">
          <div class="col-md-9">Paste the above at a Terminal prompt. It will download and start Brooklyn automatically.</div>
          <div class="col-md-3 text-rigth">Looking for <a href="{{ site.path.guide }}/start/running.html">more installation options?</a></div>
        </div>
        <p>Congratulation! Next, let's <a href="{{ site.path.guide }}/start/blueprints.html">deploy a blueprint</a>.</p>
      </div>
    </div>
  </div>
</section>

<section class="container text-center social">
    <div class="row">
        <div class="col-md-12">
            <h3 class="text-center">Get in touch</h3>
            <p>The community is available on the following channels in case you need anything</p>
        </div>
        <div class="col-sm-4">
            <a href="http://webchat.freenode.net/?channels=brooklyncentral"
               data-toggle="tooltip" data-placement="bottom" title="IRC: freenode #brooklyncentral">
                <p>
                    <span class="fa-stack fa-2x">
                        <i class="fa fa-circle-thin fa-stack-2x"></i>
                        <i class="fa fa-slack fa-stack-1x"></i>
                    </span>
                </p>
                <h4 id="deploy">IRC</h4>
            </a>
        </div>
        <div class="col-sm-4">
            <a href="https://lists.apache.org/list.html?dev@brooklyn.apache.org"
               data-toggle="tooltip" data-placement="bottom" title="Mailing list: dev@brooklyn.apache.org">
                <p>
                    <span class="fa-stack fa-2x">
                        <i class="fa fa-circle-thin fa-stack-2x"></i>
                        <i class="fa fa-envelope-o fa-stack-1x"></i>
                    </span>
                </p>
                <h4 id="deploy">Mailing list</h4>
            </a>
        </div>
        <div class="col-sm-4">
            <a href="https://twitter.com/#!/search?q=brooklyncentral"
               data-toggle="tooltip" data-placement="bottom" title="Twitter: @brooklyncentral"/>
                <p>
                    <span class="fa-stack fa-2x">
                        <i class="fa fa-circle-thin fa-stack-2x"></i>
                        <i class="fa fa-twitter fa-stack-1x"></i>
                    </span>
                </p>
                <h4 id="deploy">Twitter</h4>
            </a>
        </div>
    </div>
</section>
