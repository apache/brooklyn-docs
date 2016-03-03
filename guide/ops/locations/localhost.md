---
section: Localhost
section_position: 3
section_type: inline
---

### Localhost

If passwordless ssh login to `localhost` and passwordless `sudo` is enabled on your 
machine, you should be able to deploy blueprints with no special configuration,
just by specifying `location: localhost` in YAML.

If you use a passpharse or prefer a different key, these can be configured as follows: 

{% highlight bash %}
brooklyn.location.localhost.privateKeyFile=~/.ssh/brooklyn_key
brooklyn.location.localhost.privateKeyPassphrase=s3cr3tPASSPHRASE
{% endhighlight %}

If you encounter issues or for more information, see [SSH Keys Localhost Setup](ssh-keys.html#localhost-setup). 

If you are normally prompted for a password when executing `sudo` commands, passwordless `sudo` must also be enabled.  To enable passwordless `sudo` for your account, a line must be added to the system `/etc/sudoers` file.  To edit the file, use the `visudo` command:
{% highlight bash %}
sudo visudo
{% endhighlight %}
Add this line at the bottom of the file, replacing `username` with your own user:
{% highlight bash %}
username ALL=(ALL) NOPASSWD: ALL
{% endhighlight %}
If executing the following command does not ask for your password, then `sudo` should be setup correctly:
{% highlight bash %}
sudo ls
{% endhighlight %}