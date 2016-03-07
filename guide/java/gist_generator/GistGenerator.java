package com.acme;

import java.io.IOException;

import org.apache.brooklyn.api.entity.Entity;
import org.apache.brooklyn.api.entity.ImplementedBy;
import org.apache.brooklyn.config.ConfigKey;
import org.apache.brooklyn.core.annotation.Effector;
import org.apache.brooklyn.core.annotation.EffectorParam;
import org.apache.brooklyn.core.config.ConfigKeys;

@ImplementedBy(GistGeneratorImpl.class)
public interface GistGenerator extends Entity {

    ConfigKey<String> OAUTH_KEY = ConfigKeys.newStringConfigKey("oauth.key", "OAuth key for creating a gist",
            "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx");

    @Effector(description="Create a Gist")
    String createGist(
            @EffectorParam(name="gistName", description="Gist Name", defaultValue="Demo Gist") String gistName,
            @EffectorParam(name="fileName", description="File Name", defaultValue="Hello.java") String fileName,
            @EffectorParam(name="gistContents", description="Gist Contents", defaultValue="System.out.println(\"Hello World\");") String gistContents,
            @EffectorParam(name="oauth.key", description="OAuth key for creating a gist", defaultValue="") String oauthKey) throws IOException;

    @Effector(description="Retrieve a Gist")
    public String getGist(
            @EffectorParam(name="id", description="Gist id") String id,
            @EffectorParam(name="oauth.key", description="OAuth key for creating a gist", defaultValue="") String oauthKey) throws IOException;
}