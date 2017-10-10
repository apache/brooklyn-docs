---
layout: website-normal
title: Increase Entropy
toc: /guide/toc.json
---
# {{ page.title }}

### Checking entropy level

A lack of entropy can cause random number generation to be extremely slow.
This results in tasks like ssh to also be extremely slow.
One can check the available entropy on a machine by running the command:

```bash
cat /proc/sys/kernel/random/entropy_avail
```

It should be a value above 2000.

If you are installing Apache Brooklyn on a virtual machine, you may find that it has insufficient 
entropy. You may need to increase the Linux kernel entropy in order to speed up the ssh connections 
to the managed entities. You can install and configure `rng-tools`, or just use /dev/urandom`.


### Installing rng-tool

If you are using a RHEL 6 based OS:

```bash
sudo -i
yum -y -q install rng-tools
echo "EXTRAOPTIONS=\"-r /dev/urandom\"" | cat >> /etc/sysconfig/rngd
/etc/init.d/rngd start
```

If you are using a RHEL 7 or a systemd based system:

```bash
sudo yum -y -q install rng-tools

# Configure rng to use /dev/urandom
# Change the "ExecStart" line to:
# ExecStart=/sbin/rngd -f -r /dev/urandom
sudo vi /etc/systemd/system/multi-user.target.wants/rngd.service

sudo systemctl daemon-reload
sudo systemctl start rngd
```

If you are using a Debian-based OS:

```bash
sudo -i
apt-get -y install rng-tools
echo "HRNGDEVICE=/dev/urandom" | cat >> /etc/default/rng-tools
/etc/init.d/rng-tools start
```


### Using /dev/urandom

You can also just `mv /dev/random` then create it again linked to `/dev/urandom`:

```bash
sudo mv /dev/random /dev/random-real
sudo ln -s /dev/urandom /dev/random
```

Notice! If you map `/dev/random` to use `/dev/urandom` you will need to restart the Apache Brooklyn java process in order for the change to take place.


### More Information

The following links contain further information:

* [haveged (another solution) and general info from Digital Ocean](https://www.digitalocean.com/community/tutorials/how-to-setup-additional-entropy-for-cloud-servers-using-haveged)
* for specific OSs:
  * [for RHEL or CentOS](http://my.itwnik.com/how-to-increase-linux-kernel-entropy/)
  * [for Ubuntu](http://www.howtoforge.com/helping-the-random-number-generator-to-gain-enough-entropy-with-rng-tools-debian-lenny)
  * [for Alpine](https://wiki.alpinelinux.org/wiki/Entropy_and_randomness)


