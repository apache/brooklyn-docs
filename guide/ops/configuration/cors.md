---
title: CORS Configuration
layout: website-normal
---
# {{ page.title }}

To enable / configure [cross-origin resource sharing (CORS)](https://en.wikipedia.org/wiki/Cross-origin_resource_sharing).
The following file must be added to [`org.apache.brooklyn.rest.filter.cors.cfg`](../paths.md)

```properties
# Enables experimental support for Cross Origin Resource Sharing (CORS) filtering in Apache Brooklyn REST API.
cors.enabled=true

# @see CrossOriginResourceSharingFilter#setAllowOrigins(List<String>)
# Coma separated values list of allowed origins. Access-Control-Allow-Origin header will be returned to client if Origin header in request is matching exactly a value among the list allowed origins.
# If empty or not specified then all origins are allowed. No wildcard allowed origins are supported.
cors.allow.origins=http://host-one.example.com:8080, http://host-two.example.com, https://host-three.example.com

# @see CrossOriginResourceSharingFilter#setAllowHeaders(List<String>)
# Coma separated values list of allowed headers for preflight checks.
#cors.allow.headers=

# @see CrossOriginResourceSharingFilter#setAllowCredentials(boolean)
# The value for the Access-Control-Allow-Credentials header. If false, no header is added.
# If true, the header is added with the value 'true'. False by default.
#cors.allow.credentials=false

# @see CrossOriginResourceSharingFilter#setExposeHeaders(List<String>)
# CSV list of non-simple headers to be exposed via Access-Control-Expose-Headers.
#cors.expose.headers=

# @see CrossOriginResourceSharingFilter#setMaxAge(Integer)
# The value for Access-Control-Max-Age. If -1 then No Access-Control-Max-Age header will be send.
#cors.max.age=-1

# @see CrossOriginResourceSharingFilter#setPreflightErrorStatus(Integer)
# Preflight error response status, default is 200.
cors.preflight.error.status=200

# Do not apply CORS if response is going to be with UNAUTHORIZED status.
#cors.block.if.unauthorized=false
```

*NOTE*: You must [restart Brooklyn](../starting-stopping-monitoring.md) for these changes to be applied

Further information on client side [usage](https://developer.mozilla.org/en-US/docs/Web/HTTP/Access_control_CORS)