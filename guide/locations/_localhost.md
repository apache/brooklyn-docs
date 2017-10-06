---
section: Localhost
section_position: 10
section_type: inline
---

### Localhost

If passwordless ssh login to `localhost` and passwordless `sudo` is enabled on your 
machine, you should be able to deploy some blueprints with no special configuration,
just by specifying `location: localhost` in YAML.

If you use a passphrase or prefer a different key, these can be configured as follows:

    location:
      localhost:
        privateKeyFile=~/.ssh/brooklyn_key
        privateKeyPassphrase=s3cr3tPASSPHRASE


Alternatively, you can create a specific localhost location through the location wizard tool available within the web console.
This location will be saved as a [catalog entry]({{ book.path.guide }}/blueprints/catalog/index.html#locations-in-the-catalog) 
for easy reusability.


#### Passwordless Sudo

If you encounter issues or for more information, see [SSH Keys Localhost Setup](#localhost-setup). 

For some blueprints, passwordless sudo is required. (Try executing `sudo whoami` to see if it prompts for a password. 
To enable passwordless `sudo` for your account, a line must be added to the system `/etc/sudoers` file.  
To edit the file, use the `visudo` command:

```bash
sudo visudo
```

Add this line at the bottom of the file, replacing `username` with your own user:

```bash
username ALL=(ALL) NOPASSWD: ALL
```

If executing the following command does not ask for your password, then `sudo` has been setup correctly:

```bash
sudo whoami
```
