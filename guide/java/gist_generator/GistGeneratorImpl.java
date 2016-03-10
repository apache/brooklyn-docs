package com.acme;

import java.io.IOException;
import java.util.Collections;

import org.apache.brooklyn.core.entity.AbstractEntity;
import org.apache.brooklyn.util.text.Strings;
import org.eclipse.egit.github.core.Gist;
import org.eclipse.egit.github.core.GistFile;
import org.eclipse.egit.github.core.service.GistService;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.collect.Iterables;

public class GistGeneratorImpl extends AbstractEntity implements GistGenerator {

    private static final Logger LOG = LoggerFactory.getLogger(GistGeneratorImpl.class);

    @Override
    public String createGist(String gistName, String fileName, String gistContents, String oathToken) throws IOException {
        if (Strings.isBlank(oathToken)) oathToken = config().get(OAUTH_KEY);

        GistFile file = new GistFile();
        file.setContent(gistContents);
        Gist gist = new Gist();
        gist.setDescription(gistName);
        gist.setFiles(Collections.singletonMap(fileName, file));
        gist.setPublic(true);
        
        GistService service = new GistService();
        service.getClient().setOAuth2Token(oathToken);
        LOG.info("Creating Gist: " +  gistName);
        Gist result = service.createGist(gist);
        return result.getId();
    }
    
    @Override
    public String getGist(String id, String oathToken) throws IOException {
        if (Strings.isBlank(oathToken)) oathToken = config().get(OAUTH_KEY);

        GistService service = new GistService();
        service.getClient().setOAuth2Token(oathToken);
        Gist gist = service.getGist(id);
        return Iterables.getOnlyElement(gist.getFiles().values()).getContent();
    }
}