
{% if site.brooklyn-version contains 'SNAPSHOT' %}{% capture SNAPSHOT %}true{% endcapture %}{% endif %}

{% capture brooklyn_properties_url_path %}{{ site.path.guide }}/start/brooklyn.properties{% endcapture %}
{% capture brooklyn_properties_url_live %}{{ site.url_root }}{{ brooklyn_properties_url_path }}{% endcapture %}

{% capture brooklyn_group_id %}org.apache.brooklyn{% endcapture %}
{% capture brooklyn_group_id_path %}org/apache/brooklyn{% endcapture %}

{% capture this_repo_base_url %}https://repository.apache.org{% endcapture %}
{% capture this_repo_base_url_search %}{{ this_repo_base_url }}/index.html#nexus-search{% endcapture %}
{% capture this_repo_base_url_artifact %}{{ this_repo_base_url }}/service/local/artifact/maven/redirect{% endcapture %}

{% capture apache_snapshots_repo_groupid_url %}{{ this_repo_base_url }}/content/repositories/snapshots/{{ brooklyn_group_id_path }}{% endcapture %}
{% capture apache_releases_repo_groupid_url %}{{ this_repo_base_url }}/content/repositories/releases/{{ brooklyn_group_id_path }}{% endcapture %}

{% capture this_repo_base_url_content %}{% if SNAPSHOT %}{{ apache_snapshots_repo_groupid_url }}{% else %}{{ apache_releases_repo_groupid_url }}{% endif %}{% endcapture %}
{% capture this_dist_url_list %}{{ this_repo_base_url_content }}/brooklyn-dist/{{ site.brooklyn-version }}/{% endcapture %}

{% capture this_anything_url_search %}{{ this_repo_base_url_search }};gav~{{ brooklyn_group_id }}~~{{ site.brooklyn-version }}~~{% endcapture %}
{% capture this_dist_url_search %}{{ this_repo_base_url_search }};gav~{{ brooklyn_group_id }}~brooklyn-dist~{{ site.brooklyn-version }}~~{% endcapture %}


