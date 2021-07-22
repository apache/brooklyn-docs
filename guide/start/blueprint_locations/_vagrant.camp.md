The location in `myapp.yaml` can now be replaced with the following YAML to launch using these vagrant servers.

{% highlight yaml %}
location:
  byon:
    user: vagrant
    password: vagrant
    hosts:
    - 10.10.10.101
    - 10.10.10.102
    - 10.10.10.103
    - 10.10.10.104
{% endhighlight %}
