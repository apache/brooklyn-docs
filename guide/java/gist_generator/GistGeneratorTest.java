package com.acme;

import static org.testng.Assert.assertEquals;

import org.apache.brooklyn.api.entity.EntitySpec;
import org.apache.brooklyn.core.test.BrooklynAppUnitTestSupport;
import org.testng.annotations.Test;

public class GistGeneratorTest extends BrooklynAppUnitTestSupport {

    @Test
    public void testEntity() throws Exception {
        String oathKey = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx";
        GistGenerator entity = app.createAndManageChild(EntitySpec.create(GistGenerator.class));
        String id = entity.createGist("myGistName", "myFileName", "myGistContents", oathKey);
        
        String contents = entity.getGist(id, oathKey);
        assertEquals(contents, "myGistContents");
    }
}