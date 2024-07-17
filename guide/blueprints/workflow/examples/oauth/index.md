---
title: OAuth web request workflow
title_in_menu: OAuth
layout: website-normal
---

The following code defines an entity with a workflow which makes web requests,
automatically refreshing with an OAuth token if the error message indicates that it should,
and using backoff/retry strategies.

The blueprint assumes that a Google App requiring OAuth is set up.
This is easy done at Google, or the code should be straightforward to adapt for any other OAuth-based site.
The blueprint expects the following three values from an [externalized config provider](/guide/ops/externalized-configuration.md)
called `google-oauth`:

* `google_client_id` - the client ID for the Google App (created when the App is created there)
* `google_client_secret` - the client secret for the Google App (created when the App is created there)
* `google_refresh_token` - a refersh token acquired for the app for a logged in user;
  because this interaction is intended to be automated, it expects to be configured with a valid refresh token
  (rather than redirect a user to a webpage); this is not a token for accessing the API directly,
  but for acquiring a token to do so, and can be retrieved by interacting with the OAuth API ahead of time
  or by inspecting the traffic for a UI-based log-in

The blueprint is as follows:

{% highlight yaml %}
{% readj oauth.yaml %}
{% endhighlight %}