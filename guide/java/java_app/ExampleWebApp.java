package com.acme.autobrick;

import org.apache.brooklyn.api.entity.EntitySpec;
import org.apache.brooklyn.core.entity.AbstractApplication;
import org.apache.brooklyn.core.sensor.DependentConfiguration;
import org.apache.brooklyn.entity.database.mysql.MySqlNode;
import org.apache.brooklyn.entity.group.DynamicCluster;
import org.apache.brooklyn.entity.proxy.nginx.NginxController;
import org.apache.brooklyn.entity.webapp.tomcat.TomcatServer;

public class ExampleWebApp extends AbstractApplication {

    @Override
    public void init() {
        MySqlNode db = addChild(EntitySpec.create(MySqlNode.class)
                .configure(MySqlNode.CREATION_SCRIPT_URL, "https://bit.ly/brooklyn-visitors-creation-script"));

        DynamicCluster cluster = addChild(EntitySpec.create(DynamicCluster.class)
                .configure(DynamicCluster.MEMBER_SPEC, EntitySpec.create(TomcatServer.class)
                        .configure(TomcatServer.ROOT_WAR, 
                                "wars.root: http://search.maven.org/remotecontent?filepath=org/apache/brooklyn/example/brooklyn-example-hello-world-sql-webapp/0.8.0-incubating/brooklyn-example-hello-world-sql-webapp-0.8.0-incubating.war")
                        .configure(TomcatServer.JAVA_SYSPROPS.subKey("brooklyn.example.db.url"),
                                DependentConfiguration.formatString("jdbc:%s%s?user=%s&password=%s",
                                        DependentConfiguration.attributeWhenReady(db, MySqlNode.DATASTORE_URL),
                                        "visitors", "brooklyn", "br00k11n"))));
        
        addChild(EntitySpec.create(NginxController.class)
                .configure(NginxController.SERVER_POOL, cluster));
    }
}
