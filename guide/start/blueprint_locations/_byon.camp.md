
Replace the hosts, user and password in the example below with your own server details, then replace the location in your `myapp.yaml` with this.

{% highlight yaml %}
location:
  byon:
    user: myuser
    password: mypassword
    # or...
    #privateKeyFile: ~/.ssh/my.pem
    hosts:
    - 192.168.0.18
    - 192.168.0.19
{% endhighlight %}
