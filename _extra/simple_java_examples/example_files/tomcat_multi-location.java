// TODO Untested code; see brooklyn-example for better maintained examples!
public class TomcatFabricApp extends AbstractApplication {
    @Override
    public void init() {
        addChild(EntitySpec.create(DynamicFabric.class)
                .configure("displayName", "WebFabric")
                .configure("displayNamePrefix", "")
                .configure("displayNameSuffix", " web cluster")
                .configure("dynamiccluster.memberspec", EntitySpec.create(ControlledDynamicWebAppCluster.class)
                        .configure("cluster.initial.size", 2)
                        .configure("dynamiccluster.memberspec", : EntitySpec.create(TomcatServer.class)
                                .configure("httpPort", "8080+")
                                .configure("war", "/path/to/booking-mvc.war"))));
    }
}
