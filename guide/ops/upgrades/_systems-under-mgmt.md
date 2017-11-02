
## Upgrading Systems Under Management

Blueprints can encode update processes for the systems they describe.
The mechanisms for updating systems vary, depending whether it is stateless or stateful,
whether following an immutable pattern (replacing components) 
or doing it on box (traditional, possibly taking systems out of action while upgrading), 
and whether applying an upgrade to many resources on a rolling fashion (repaving, blue-green).
For this reason there is not a one-size-fits-all upgrade pattern to use in blueprints,
but there are some common patterns that may be applicable:

* Defining an `upgrade` effector on nodes, and on a cluster to apply to all nodes
* Using a config key such as `version` which can be updated and reapplied
* Exposing a `deploy` effector to pass files that should be run, such as WAR files,
  and invoking this effector with newer versions of WAR files to install

There are many more, and if you've written some good pieces to share,
please consider contributing them so others can take advantage of them!



 
 

