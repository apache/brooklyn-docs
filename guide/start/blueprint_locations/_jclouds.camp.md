
As an example, here is a configuration for [Amazon Web Services (AWS)](http://www.aws.amazon.com){:target="_blank"}. Swap the identity and credential with your AWS account details, then replace the location in your `myapp.yaml` with this.

{% highlight yaml %}
location:
  jclouds:aws-ec2:
    identity: ABCDEFGHIJKLMNOPQRST
    credential: s3cr3tsq1rr3ls3cr3tsq1rr3ls3cr3tsq1rr3l
{% endhighlight %}

