---
title: Increase System Resource Limits
---

If you encounter the following error:

    Caused by: java.io.IOException: Too many open files
            at java.io.UnixFileSystem.createFileExclusively(Native Method)[:1.8.0

Please check and increase the limit for opened files.

If you encounter the error below, e.g. when running with many entities, please consider **increasing the ulimit**:

    java.lang.OutOfMemoryError: unable to create new native thread

On the VM running Apache Brooklyn, it is recommended that nproc and nofile are reasonably high 
(e.g. 16384 or higher; a value of 1024 is often the default).

## For Centos 7
To check the current limits, you will need to know the PID for the brooklyn process. You can find
this by running `systemctl status brooklyn` and checking the `Main PID` line.

To see the current limits, run `cat /proc/<brooklyn PID>/limits` replacing <brooklyn PID> with the Main PID
from above

To override the default limits, you will need to create a `limits.conf` and populate it with the required
values as follows:

```
mkdir -p /etc/systemd/system/brooklyn.service.d

cat > /etc/systemd/system/brooklyn.service.d/limits.conf << EOF
[Service]
LimitNOFILE=16384
LimitNPROC=16384
EOF
```

You will then need to reload the systemctl daemon and restart brooklyn:

```
systemctl daemon-reload
systemctl restart brooklyn
```

To check the new limits, you will need to obtain the new brooklyn PID by running `systemctl status brooklyn`
and `cat`ing the process limits as above


## For Centos 6
Please check the limit for opened files `cat /proc/sys/fs/file-max` and increase it.
You can increase the maximum limit of opened files by setting `fs.file-max` in `/etc/sysctl.conf`.
and then running `sudo sysctl -p` to apply the changes.

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
