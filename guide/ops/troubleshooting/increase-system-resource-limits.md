---
layout: website-normal
title: Increase System Resource Limits
toc: /guide/toc.json
---
# {{ page.title }}

If you encounter the following error:

    Caused by: java.io.IOException: Too many open files
            at java.io.UnixFileSystem.createFileExclusively(Native Method)[:1.8.0

Please check the limit for opened files `cat /proc/sys/fs/file-max` and increase it.
You can increase the maximum limit of opened files by setting `fs.file-max` in `/etc/sysctl.conf`.
and then running `sudo sysctl -p` to apply the changes.


If you encounter the error below, e.g. when running with many entities, please consider **increasing the ulimit**:

    java.lang.OutOfMemoryError: unable to create new native thread

On the VM running Apache Brooklyn, it is recommended that nproc and nofile are reasonably high 
(e.g. 16384 or higher; a value of 1024 is often the default).

If you want to check the current limits run `ulimit -a`. Alternatively, if Brooklyn is run as a 
different user (e.g. with user name "brooklyn"), then instead run `ulimit -a -u brooklyn`.

For RHEL (and CentOS) distributions, you can increase the limits by running
`sudo vi /etc/security/limits.conf` and adding (if it is "brooklyn" user running Apache Brooklyn):

    brooklyn           soft    nproc           16384
    brooklyn           hard    nproc           16384
    brooklyn           soft    nofile          16384
    brooklyn           hard    nofile          16384

Generally you do not have to reboot to apply ulimit values. They are set per session.
So after you have the correct values, quit the ssh session and log back in.

For more details, see one of the many posts such as 
[http://tuxgen.blogspot.co.uk/2014/01/centosrhel-ulimit-and-maximum-number-of.html](http://tuxgen.blogspot.co.uk/2014/01/centosrhel-ulimit-and-maximum-number-of.html).
