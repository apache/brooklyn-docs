---
title: Not Using Submodules
layout: website-normal
---

If you don't want to use submodules, this will achieve the same result:

{% highlight bash %}
mkdir apache-brooklyn
cd apache-brooklyn
git clone http://github.com/apache/brooklyn/
git clone http://github.com/apache/brooklyn-ui/
git clone http://github.com/apache/brooklyn-server/
git clone http://github.com/apache/brooklyn-client/
git clone http://github.com/apache/brooklyn-docs/
git clone http://github.com/apache/brooklyn-library/
git clone http://github.com/apache/brooklyn-dist/
ln -s brooklyn/pom.xml .
mvn clean install
{% endhighlight %}
