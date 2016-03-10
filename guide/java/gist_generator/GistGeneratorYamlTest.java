package com.acme;

import static org.testng.Assert.assertEquals;

import org.apache.brooklyn.api.entity.Entity;
import org.apache.brooklyn.camp.brooklyn.AbstractYamlTest;
import org.apache.brooklyn.core.entity.Entities;
import org.testng.annotations.Test;

import com.google.common.base.Joiner;
import com.google.common.collect.Iterables;

public class GistGeneratorYamlTest extends AbstractYamlTest {

    private String contents;

    @Test
    public void testEntity() throws Exception {
        String oathKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
        
        String yaml = Joiner.on("\n").join(
            "name: my test",
            "services:",
            "- type: com.acme.GistGenerator",
            "  brooklyn.config:",
            "    oauth.key: "+oathKey);
        
        Entity app = createAndStartApplication(yaml);
        waitForApplicationTasks(app);

        Entities.dumpInfo(app);

        GistGenerator entity = (GistGenerator) Iterables.getOnlyElement(app.getChildren());
        String id = entity.createGist("myGistName", "myFileName", "myGistContents", null);
        
        contents = entity.getGist(id, null);
        assertEquals(contents, "myGistContents");
    }
}