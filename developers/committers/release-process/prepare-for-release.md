---
layout: website-normal
title: Prepare the project for a release
navgroup: developers
---

1. Make sure all unit and integration tests are passing.
2. Follow the [classic](https://github.com/apache/brooklyn-dist/blob/master/dist/licensing/README.md#update-license-information)
   and [karaf](https://github.com/apache/brooklyn-dist/pull/63) instructions to
   update the licenses of source and binary dependencies.
   For step 5 of the the karaf version (create a temporary pom.xml), the following template can be used:
   ```
   <project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">

    <modelVersion>4.0.0</modelVersion>
    <groupId>foo</groupId>
    <artifactId>bar</artifactId>
    <version>baz</version>
    <packaging>pom</packaging>

    <dependencies>
        <!-- paste dependencies generated in step 4 -->
    </dependencies>
   </project>
   ```
3. Update the [release notes](https://github.com/apache/brooklyn-docs/blob/master/guide/misc/release-notes.md). To help
   in the process [list merged PRs](https://gist.github.com/sjcorbett/72ed944b06ce3a138fbe516e8d36f624) after a ceratin date.
