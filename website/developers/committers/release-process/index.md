---
layout: website-normal
title: Release Process
navgroup: developers
children:
- { path: prerequisites.md }
- { path: environment-variables.md }
- { path: release-version.md }
- { path: make-release-artifacts.md }
- { path: verify-release-artifacts.md }
- { path: publish-temp.md }
- { path: vote.md }
- { path: fix-release.md }
- { path: publish.md }
- { path: announce.md }
---
1. [Preparing for a release](prepare-for-release.html) - How to prepare the project for a release
2. [Prerequisites](prerequisites.html) - steps that a new release manager must do (but which only need to be done once)
3. [Set environment variables](environment-variables.html) - many example snippets here use environment variables to
   avoid repetition - this page describes what they are
4. [Create a release branch and set the version](release-version.html)
5. [Make the release artifacts](make-release-artifacts.html)
6. [Verify the release artifacts](verify-release-artifacts.html)
7. [Publish the release artifacts to the staging area](publish-temp.html)
8. [Vote on the dev@brooklyn list](vote.html)
  1. If the vote fails - [fix the release branch](fix-release.html) and resume from step 4
9. [Publish the release artifacts to the public location](publish.html)
10. [Announce the release](announce.html)
