package com.acme.autobrick;

import org.apache.brooklyn.api.entity.EntitySpec;
import org.apache.brooklyn.api.policy.PolicySpec;
import org.apache.brooklyn.api.sensor.AttributeSensor;
import org.apache.brooklyn.api.sensor.EnricherSpec;
import org.apache.brooklyn.core.entity.AbstractApplication;
import org.apache.brooklyn.core.sensor.DependentConfiguration;
import org.apache.brooklyn.core.sensor.Sensors;
import org.apache.brooklyn.enricher.stock.Enrichers;
import org.apache.brooklyn.entity.database.mysql.MySqlNode;
import org.apache.brooklyn.entity.group.DynamicCluster;
import org.apache.brooklyn.entity.proxy.nginx.NginxController;
import org.apache.brooklyn.entity.webapp.tomcat.TomcatServer;
import org.apache.brooklyn.policy.autoscaling.AutoScalerPolicy;
import org.apache.brooklyn.policy.ha.ServiceFailureDetector;
import org.apache.brooklyn.policy.ha.ServiceReplacer;
import org.apache.brooklyn.policy.ha.ServiceRestarter;
import org.apache.brooklyn.util.time.Duration;

public class ExampleWebApp extends AbstractApplication {

    @Override
    public void init() {
        AttributeSensor<Double> reqsPerSecPerNodeSensor = Sensors.newDoubleSensor(
                "webapp.reqs.perSec.perNode",
                "Reqs/sec averaged over all nodes");
        
        MySqlNode db = addChild(EntitySpec.create(MySqlNode.class)
                .configure(MySqlNode.CREATION_SCRIPT_URL, "https://bit.ly/brooklyn-visitors-creation-script"));

        DynamicCluster cluster = addChild(EntitySpec.create(DynamicCluster.class)
                .displayName("Cluster")
                .configure(DynamicCluster.MEMBER_SPEC, EntitySpec.create(TomcatServer.class)
                        .configure(TomcatServer.ROOT_WAR, 
                                "http://search.maven.org/remotecontent?filepath=org/apache/brooklyn/example/brooklyn-example-hello-world-sql-webapp/0.8.0-incubating/brooklyn-example-hello-world-sql-webapp-0.8.0-incubating.war")
                        .configure(TomcatServer.JAVA_SYSPROPS.subKey("brooklyn.example.db.url"),
                                DependentConfiguration.formatString("jdbc:%s%s?user=%s&password=%s",
                                        DependentConfiguration.attributeWhenReady(db, MySqlNode.DATASTORE_URL),
                                        "visitors", "brooklyn", "br00k11n"))
                        .policy(PolicySpec.create(ServiceRestarter.class)
                                .configure(ServiceRestarter.FAIL_ON_RECURRING_FAILURES_IN_THIS_DURATION, Duration.minutes(5)))
                        .enricher(EnricherSpec.create(ServiceFailureDetector.class)
                                .configure(ServiceFailureDetector.ENTITY_FAILED_STABILIZATION_DELAY, Duration.seconds(30))))
                .policy(PolicySpec.create(ServiceReplacer.class))
                .policy(PolicySpec.create(AutoScalerPolicy.class)
                        .configure(AutoScalerPolicy.METRIC, reqsPerSecPerNodeSensor)
                        .configure(AutoScalerPolicy.METRIC_LOWER_BOUND, 1)
                        .configure(AutoScalerPolicy.METRIC_UPPER_BOUND, 3)
                        .configure(AutoScalerPolicy.RESIZE_UP_STABILIZATION_DELAY, Duration.seconds(2))
                        .configure(AutoScalerPolicy.RESIZE_DOWN_STABILIZATION_DELAY, Duration.minutes(1))
                        .configure(AutoScalerPolicy.MAX_POOL_SIZE, 3))
                .enricher(Enrichers.builder().aggregating(TomcatServer.REQUESTS_PER_SECOND_IN_WINDOW)
                        .computingAverage()
                        .fromMembers()
                        .publishing(reqsPerSecPerNodeSensor)
                        .build()));
        addChild(EntitySpec.create(NginxController.class)
                .configure(NginxController.SERVER_POOL, cluster)
                .configure(NginxController.STICKY, false));
    }
}
