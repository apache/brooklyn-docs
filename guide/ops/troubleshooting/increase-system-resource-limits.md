---
layout: website-normal
title: Increase System Resource Limits
toc: /guide/toc.json
---

If you encounter the error below, e.g. when running with many entities, please consider **increasing the ulimit**:

    java.lang.OutOfMemoryError: unable to create new native thread

On the VM running Apache Brooklyn, it is recommended that nproc and nofile are reasonably high 
(e.g. 16384 or higher; a value of 1024 is often the default).

If you want to check the current limits run `ulimit -a`. Alternatively, if Brooklyn is run as a 
different user (e.g. with user name "adalovelace"), then instead run `ulimit -a -u adalovelace`.

For RHEL (and CentOS) distributions, you can increase the limits by running
`sudo vi /etc/security/limits.conf` and adding (if it is "adalovelace" user running Apache Brooklyn):

    adalovelace           soft    nproc           16384
    adalovelace           hard    nproc           16384
    adalovelace           soft    nofile          16384
    adalovelace           hard    nofile          16384

Generally you do not have to reboot to apply ulimit values. They are set per session.
So after you have the correct values, quit the ssh session and log back in.

For more details, see one of the many posts such as 
[http://tuxgen.blogspot.co.uk/2014/01/centosrhel-ulimit-and-maximum-number-of.html](http://tuxgen.blogspot.co.uk/2014/01/centosrhel-ulimit-and-maximum-number-of.html).
