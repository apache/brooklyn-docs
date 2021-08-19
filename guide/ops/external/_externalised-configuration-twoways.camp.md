You can use `$brooklyn:external` directly:

{% highlight yaml %}
name: MyApplication
brooklyn.config:
  example: $brooklyn:external("supplier", "key")
{% endhighlight %}

or embed the `external` function inside another `$brooklyn` DSL function, such as `$brooklyn:formatString`:

{% highlight yaml %}
name: MyApplication
brooklyn.config:
  example: $brooklyn:formatString("%s", external("supplier", "key"))
{% endhighlight %}
