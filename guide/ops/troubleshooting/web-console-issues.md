---
layout: website-normal
title: Web Console Issues
toc: /guide/toc.json
---

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

## Windows Defender may report a false-postive virus definiton match when downloading br.exe

On older versions of the Windows Defender malware definitions, the `br.exe` download was erroneously
flagged as containing a virus. The executable has been scanned against multiple antivirus protection
providers and no infection has been found. As of 15 Sept. 2021, Microsoft has confirmed that the detection
has been removed.

Please follow the steps below to clear cached detection files and obtain the latest malware definitions.

1. Open command prompt as Administrator and change directory to the _Windows Defender_ directory
2. Run `MpCmdRun.exe -removedefinitions -dynamicsignatures`
3. Run `MpCmdRun.exe -SignatureUpdate`

Alternatively, the latest definition is available for download here: [https://www.microsoft.com/en-us/wdsi/definitions]

