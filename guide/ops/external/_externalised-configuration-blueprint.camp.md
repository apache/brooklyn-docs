{% highlight yaml %}
name: MyApplication
services:
- type: brooklyn.entity.webapp.jboss.JBoss7Server
  name: AppServer HelloWorld
  brooklyn.config:
    wars.root: https://search.maven.org/remotecontent?filepath=org/apache/brooklyn/example/brooklyn-example-hello-world-sql-webapp/0.12.0/brooklyn-example-hello-world-sql-webapp-0.12.0.war # BROOKLYN_VERSION
    http.port: 8080+
    java.sysprops:
      brooklyn.example.db.url: 
        $brooklyn:formatString:
          - "jdbc:postgresql://%s/myappdb?user=%s&password=%s"
          - $brooklyn:external("servers", "postgresql")
          - $brooklyn:external("credentials", "postgresql-user")
          - $brooklyn:external("credentials", "postgresql-password")
{% endhighlight %}
