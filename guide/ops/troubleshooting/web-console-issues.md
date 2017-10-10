---
layout: website-normal
title: Web Console Issues
toc: /guide/toc.json
---
# {{ page.title }}

## Page Does Not Load in Chrome, Saying ""Waiting for available socket..."

If you find that the Web Console does not load in Chrome (giving a message "Waiting for available 
socket..."), there are two possible explanations.

The first reason is that another tab for the same host:port has a login dialog that is prompting  
for a username and password. This will block other tabs that are also trying to connect. The 
solution is to login at the first tab, or to close that tab.

A second possible reason is that there are too many open connections in Chrome to that domain. 
There is a limit in Chrome for the number of open socket connections to a given domain. If this
is exceeded, subsequent tabs that try to connect will wait for an available socket.

For more information, see 
[http://stackoverflow.com/questions/23679968/chrome-hangs-after-certain-amount-of-data-transfered-waiting-for-available-soc](http://stackoverflow.com/questions/23679968/chrome-hangs-after-certain-amount-of-data-transfered-waiting-for-available-soc).

[chrome://net-internals/#sockets](chrome://net-internals/#sockets) is also a useful diagnostic tool.
