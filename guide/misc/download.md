---
layout: website-normal
title: Downloads
---
# {{ page.title }}


{% if book.brooklyn.is_snapshot %}
**The downloads on this page have not been voted on and should be used at your own risk.
The latest stable release can be accessed on the [main download page]({{ book.path.website }}/download/).**
{% endif %}


## Download Version {{ book.brooklyn_version }}

<table class="table">
  <tr>
	<th style='text-align:left'>Download</th>
	<th style='text-align:left'>File/Format</th>
	<th>checksums <small><a href="{{ book.path.website }}/download/verify.html" title='Instructions on verifying the integrity of your downloads.{% if book.brooklyn.is_snapshot %} May not be available for SNAPSHOT artifacts.{% endif %}'>(?)</a></small></th>
  </tr>
  <tr>
	<td style='text-align:left;vertical-align:top' rowspan='2'>Binary distribution<br />Server &amp; client</td>
	<td style='text-align:left'><a href='{{ book.brooklyn.download_prefix }}-bin.tar.gz' title='Download TGZ archive'>apache-brooklyn-{{ book.brooklyn_version }}-bin.tar.gz</a></td>
	<td ><small>
	  {% if book.brooklyn.is_release %}<a href='{{ book.brooklyn.hash_download_prefix }}-bin.tar.gz.asc'>PGP</a>, {% endif %}
	  <a href='{{ book.hash_brooklyn.download_prefix }}-bin.tar.gz.sha1'>SHA1</a></small></td>
  </tr>
  <tr>
	<td style='text-align:left'><a href='{{ book.brooklyn.download_prefix }}-bin.zip' title='Download ZIP archive'>apache-brooklyn-{{ book.brooklyn_version }}-bin.zip</a></td>
	<td><small>
	  {% if book.brooklyn.is_release %}<a href='{{ book.brooklyn.hash_download_prefix }}-bin.zip.asc'>PGP</a>, {% endif %}
	  <a href='{{ book.brooklyn.hash_download_prefix }}-bin.zip.sha1'>SHA1</a></small></td>
  </tr>
  <tr>
	<td style='text-align:left;vertical-align:top'>RPM package<br />CentOS7, RHEL7, etc.</td>
	<td style='text-align:left'><a href='{{ book.brooklyn.download_prefix }}-1.noarch.rpm' title='Download RPM package'>apache-brooklyn-{{ book.brooklyn_version }}-1.noarch.rpm</a></td>
	<td><small>
	  {% if book.brooklyn.is_release %}<a href='{{ book.brooklyn.hash_download_prefix }}-1.noarch.rpm.asc'>PGP</a>, {% endif %}
	  <a href='{{ book.brooklyn.hash_download_prefix }}-1.noarch.rpm.sha1'>SHA1</a></small></td>
  </tr>
  <tr>
	<td style='text-align:left;vertical-align:top'>DEB package<br />Ubuntu, Debian, etc.</td>
	<td style='text-align:left'><a href='{{ book.brooklyn.download_prefix }}.deb' title='Download DEB package'>apache-brooklyn-{{ book.brooklyn_version }}.deb</a></td>
	<td><small>
	  {% if book.brooklyn.is_release %}<a href='{{ book.brooklyn.hash_download_prefix }}.deb.asc'>PGP</a>, {% endif %}
	  <a href='{{ book.brooklyn.hash_download_prefix }}.deb.sha1'>SHA1</a></small></td>
  </tr>
  <tr>
	<td style='text-align:left;vertical-align:top' rowspan='6'>Client CLI only</td>
	<td style='text-align:left'><a href='{{ book.brooklyn.download_prefix }}-client-cli-linux.tar.gz' title='Download client CLI linux TGZ archive'>apache-brooklyn-{{ book.brooklyn_version }}-client-cli-linux.tar.gz</a></td>
	<td ><small>
	  {% if book.brooklyn.is_release %}<a href='{{ book.brooklyn.hash_download_prefix }}-client-cli-linux.tar.gz.asc'>PGP</a>, {% endif %}
	  <a href='{{ book.hash_brooklyn.download_prefix }}-client-cli-linux.tar.gz.sha1'>SHA1</a></small></td>
  </tr>
  <tr>
	<td style='text-align:left'><a href='{{ book.brooklyn.download_prefix }}-client-cli-linux.zip' title='Download client CLI linux ZIP archive'>apache-brooklyn-{{ book.brooklyn_version }}-client-cli-linux.zip</a></td>
	<td><small>
	  {% if book.brooklyn.is_release %}<a href='{{ book.brooklyn.hash_download_prefix }}-client-cli-linux.zip.asc'>PGP</a>, {% endif %}
	  <a href='{{ book.brooklyn.hash_download_prefix }}-client-cli-linux.zip.sha1'>SHA1</a></small></td>
  </tr>
  <tr>
	<td style='text-align:left'><a href='{{ book.brooklyn.download_prefix }}-client-cli-macosx.tar.gz' title='Download client CLI macosx TGZ archive'>apache-brooklyn-{{ book.brooklyn_version }}-client-cli-macosx.tar.gz</a></td>
	<td ><small>
	  {% if book.brooklyn.is_release %}<a href='{{ book.brooklyn.hash_download_prefix }}-client-cli-macosx.tar.gz.asc'>PGP</a>, {% endif %}
	  <a href='{{ book.hash_brooklyn.download_prefix }}-client-cli-macosx.tar.gz.sha1'>SHA1</a></small></td>
  </tr>
  <tr>
	<td style='text-align:left'><a href='{{ book.brooklyn.download_prefix }}-client-cli-macosx.zip' title='Download client CLI macosx ZIP archive'>apache-brooklyn-{{ book.brooklyn_version }}-client-cli-macosx.zip</a></td>
	<td><small>
	  {% if book.brooklyn.is_release %}<a href='{{ book.brooklyn.hash_download_prefix }}-client-cli-macosx.zip.asc'>PGP</a>, {% endif %}
	  <a href='{{ book.brooklyn.hash_download_prefix }}-client-cli-macosx.zip.sha1'>SHA1</a></small></td>
  </tr>
  <tr>
	<td style='text-align:left'><a href='{{ book.brooklyn.download_prefix }}-client-cli-windows.tar.gz' title='Download client CLI windows TGZ archive'>apache-brooklyn-{{ book.brooklyn_version }}-client-cli-windows.tar.gz</a></td>
	<td ><small>
	  {% if book.brooklyn.is_release %}<a href='{{ book.brooklyn.hash_download_prefix }}-client-cli-windows.tar.gz.asc'>PGP</a>, {% endif %}
	  <a href='{{ book.hash_brooklyn.download_prefix }}-client-cli-windows.tar.gz.sha1'>SHA1</a></small></td>
  </tr>
  <tr>
	<td style='text-align:left'><a href='{{ book.brooklyn.download_prefix }}-client-cli-windows.zip' title='Download client CLI windows ZIP archive'>apache-brooklyn-{{ book.brooklyn_version }}-client-cli-windows.zip</a></td>
	<td><small>
	  {% if book.brooklyn.is_release %}<a href='{{ book.brooklyn.hash_download_prefix }}-client-cli-windows.zip.asc'>PGP</a>, {% endif %}
	  <a href='{{ book.brooklyn.hash_download_prefix }}-client-cli-windows.zip.sha1'>SHA1</a></small></td>
  </tr>
  <tr>
	<td style='text-align:left;vertical-align:top' rowspan='2'>Source code</td>
	<td style='text-align:left'><a href='{{ book.brooklyn.download_prefix }}-src.tar.gz' title='Download source TGZ archive'>apache-brooklyn-{{ book.brooklyn_version }}-src.tar.gz</a></td>
	<td ><small>
	  {% if book.brooklyn.is_release %}<a href='{{ book.brooklyn.hash_download_prefix }}-src.tar.gz.asc'>PGP</a>, {% endif %}
	  <a href='{{ book.hash_brooklyn.download_prefix }}-src.tar.gz.sha1'>SHA1</a></small></td>
  </tr>
  <tr>
	<td style='text-align:left'><a href='{{ book.brooklyn.download_prefix }}-src.zip' title='Download source ZIP archive'>apache-brooklyn-{{ book.brooklyn_version }}-src.zip</a></td>
	<td><small>
	  {% if book.brooklyn.is_release %}<a href='{{ book.brooklyn.hash_download_prefix }}-src.zip.asc'>PGP</a>, {% endif %}
	  <a href='{{ book.brooklyn.hash_download_prefix }}-src.zip.sha1'>SHA1</a></small></td>
  </tr>
</table>


## Release Notes

Release notes can be found [here](release-notes.md).

<a name="maven"></a>

## Maven

If you use Maven, you can add Brooklyn with the following in your pom:

<pre><code class="lang-xml">    &lt;!-- include all Brooklyn items in our project --&gt;
    &lt;dependencies&gt;
        &lt;dependency&gt;
            &lt;groupId&gt;org.apache.brooklyn&lt;/groupId&gt;
            &lt;artifactId&gt;brooklyn-all&lt;/artifactId&gt;
            &lt;version&gt;{{ book.brooklyn_version }}&lt;/version&gt;
        &lt;/dependency&gt;
    &lt;/dependencies&gt;</code></pre>

`brooklyn-all` brings in all dependencies, including jclouds.
If you prefer a smaller repo you might want just ``brooklyn-core``,  ``brooklyn-policies``, 
and some of ``brooklyn-software-webapp``,  ``brooklyn-software-database``, ``brooklyn-software-messaging``, or others
(browse the full list [here]({{ this_anything_url_search }})).

If you wish to use the Apache snapshot repo, you can add this to you `pom.xml`:

```xml
<!-- include repos for snapshot items and other dependencies -->
    <repositories>
        <repository>
            <id>apache-nexus-snapshots</id>
            <name>Apache Nexus Snapshots</name>
            <url>https://repository.apache.org/content/repositories/snapshots</url>
            <releases> <enabled>false</enabled> </releases>
            <snapshots> <enabled>true</enabled> </snapshots>
        </repository>
    </repositories>
```

{% if SNAPSHOT %}
**Please note**: to add a snapshot version of Brooklyn as a dependency to your project, 
you must either have Brooklyn built locally or one of these snapshot repositories in your POM.
{% endif %}


<a name="source"></a>

## Source Code

Source code is hosted at [github.com/apache/brooklyn](http://github.com/apache/brooklyn),
with this version in branch [{{ book.brooklyn.git_branch }}]({{ book.brooklyn.url.git }}).
These locations have a `README.md` in the root which explains how to get the code including
submodules.

Useful information on working with the source is [here]({{ book.path.guide }}/dev/code).
