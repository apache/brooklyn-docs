---
title: Uploading Script and Configuration Files
---

Blueprints often require that parameterized scripts and configuration files are available to be copied to the
target VM. These must be URLs resolvable from the Brooklyn instance, or on the Brooklyn classpath.

There are two types of file that can be uploaded: plain files and templated files. A plain
file is uploaded unmodified. A templated file is interpreted as a [FreeMarker](http://freemarker.org)
template. This supports a powerful set of substitutions. In brief, anything (unescaped) of the form
`${name}` will be substituted, in this case looking up "name" for the value to use.


## Writing templates

Templated files (be they configuration files or scripts) give a powerful way to inject dependent
configuration when installing an entity (e.g. for customising the install, or for referencing the
connection details of another entity). Available substitutions are:

| Substitution              | Effect                                                             |
|---------------------------|--------------------------------------------------------------------|
| `${config['key']}`        | Equivalent to `entity.config().get(key)`                           |
| `${attribute['key']}`     | Equivalent to `entity.sensors().get(key)`                          |
| `${mgmt['key']}`          | Loads the value for `key` from the management context's properties |
| `${entity.foo}`           | FreeMarker calls `getFoo` on the entity                            |
| `${driver.foo}`           | FreeMarker calls `getFoo` on the entity's [driver](java/entity.md#things-to-know) |
| `${location.foo}`         | FreeMarker calls `getFoo` on the entity's location                 |
| `${javaSysProps.foo.bar}` | Loads the system property named `foo.bar`                          |

Additional substitutions can be given per-entity by setting the `template.substitutions` key. For example,
to include the address of an entity called db:

    brooklyn.config
      template.substitutions:
        databaseAddress: $brooklyn:entity("db").attributeWhenReady("host.address")

The value can be referenced in a template with `${databaseAddress}`.

FreeMarker evaluates all expressions between `${}` which may be inappropriate in certain kinds of files.
To include the literal `${value}` in a script you might:
 * specify a [raw string literal](http://freemarker.org/docs/dgui_template_exp.html#dgui_template_exp_direct_string):
   `${r"${value}"}`
 * use the [noparse](http://freemarker.org/docs/ref_directive_noparse.html) directive: `<#noparse>${value}</#noparse>`
 * use FreeMarker's [alternative syntax](http://freemarker.org/docs/dgui_misc_alternativesyntax.html).

A common pattern for templating Bash files is to set environment variables at the top of the script and to surround
the rest of its contents with `noparse`. For example:

    GREETING=${config['greeting']}
    NAME=${config['name']}
    
    <#noparse>
    # The remainder of the script can be written as normal.
    echo "${GREETING}, ${NAME}!"
    </#noparse>


## Using templates in blueprints

Files can be uploaded at several stages of an entity's lifecycle:

| Config key             | Copied before lifecycle phase | Templated | Relative to  |
|------------------------|-------------------------------|-----------|--------------|
| `files.preinstall`     | Pre-install                   | ✕         | `installDir` |
| `files.install`        | Install                       | ✕         | `installDir` |
| `files.customize`      | Pre-customize command         | ✕         | `installDir` |
| `files.runtime`        | Pre-launch command            | ✕         | `run.dir`    |
| `templates.preinstall` | Pre-install                   | ✓         | `installDir` |
| `templates.install`    | Install                       | ✓         | `installDir` |
| `templates.customize`  | Pre-customize command         | ✓         | `installDir` |
| `templates.runtime`    | Pre-launch command            | ✓         | `run.dir`    |

Each key accepts a map of values where a key indicates the source of a file and a value its destination
on the instance.

Files can be referenced as URLs. This includes support for:
 * `classpath://mypath/myfile.bat`, which looks for the given (fully qualified) resource on the Brooklyn classpath
   or inside the bundle, if using the OSGi version of Brooklyn with a catalog blueprint.
 * `file://`, which looks for the given file on the Brooklyn server, and
 * `http://`, which requires the file to be accessible from the Brooklyn instance.

Destinations may be absolute or relative. Absolute paths need not exist beforehand, but Brooklyn's SSH user must
have sufficient permission to create all parent directories and the file itself. Relative paths are copied as
described in the table above.


### Example

    files.preinstall:
      # Reference a fixed resource
      classpath://com/acme/installAcme.ps1: C:\\acme\installAcme.ps1
      # Inject the source from a config key
      $brooklyn:config("acme.conf"): C:\\acme\acme.conf


## Windows notes

* When writing scripts for Windows ensure that each line ends with "\r\n", rather than just "\n".
* The backslash character (\\) must be escaped in paths. For example: `C:\\install7zip.ps1`.
