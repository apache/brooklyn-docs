---
title: Code Structure
layout: website-normal
---
# {{ page.title }}

Brooklyn is split into the following subprojects:

* **brooklyn-server**:
    * **api**: the pure-Java interfaces for interacting with the system
    * **camp**: the components for a server which speaks with the CAMP REST API and understands the CAMP YAML plan language
    * **core**: the base class implementations for entities and applications, entity traits, locations, policies, sensor and effector support, tasks, and more
    * **karaf**: OSGi support
    * **launcher**: for launching brooklyn, either using a main method or invoked from the cli project
    * **locations**: specific location integrations
        * **jclouds**: integration with many cloud APIs and providers via Apache jclouds
    * **logging**: how we enable configurable logging
        * **logback-includes**: Various helpful logback XML files that can be included; does not contain logback.xml 
        * **logback-xml**: Contains a logback.xml that references the include files in brooklyn-logback-includes
    * **parent**: a meta-project parent to collect dependencies and other maven configuration for re-use  
    * **policy**: collection of useful policies for automating entity activity
    * **rest**: supporting the REST API
        * **rest-api**: The API classes for the Brooklyn REST api
        * **rest-client**: A client Java implementation for using the Brooklyn REST API 
        * **rest-server**: The server-side implementation of the Brooklyn REST API
    * **server-cli**: implementation of the Brooklyn *server* command line interface; not to be confused with the client CLI
    * **software**: support frameworks for creating entities which mainly launch software processes on machines
        * **base**: software process lifecycle abstract classes and drivers (e.g. SSH) 
        * **winrm**: support for connecting to Windows machines
    * **test-framework**: provides Brooklyn entities for building YAML tests for other entities
    * **test-support**: provides Brooklyn-specific support for Java TestNG tests, used by nearly all projects in scope ``test``, building on `utils/test-support`
    * **utils**: projects with lower level utilities
        * **common**: Utility classes and methods developed for Brooklyn but not dependent on Brooklyn
        * **groovy**: Groovy extensions and utility classes and methods developed for Brooklyn but not dependent on Brooklyn
        * **jmx/jmxmp-ssl-agent**: An agent implementation that can be attached to a Java process, to give expose secure JMXMP
        * **jmx/jmxrmi-agent**: An agent implementation that can be attached to a Java process, to give expose JMX-RMI without requiring all high-number ports to be open
        * **rest-swagger**: Swagger REST API utility classes and methods developed for Brooklyn but not dependent on Brooklyn
        * **test-support**: Test utility classes and methods developed for Brooklyn but not dependent on Brooklyn

* **brooklyn-ui**: Javascript web-app for the brooklyn management web console (builds a WAR)

* **brooklyn-library**: a library of useful blueprints
    * **examples**: some canonical examples
    * **qa**: longevity and stress tests
    * **sandbox**: experimental items
    * **software**: blueprints for software processes
        * **webapp**: web servers (JBoss, Tomcat), load-balancers (Nginx), and DNS (Geoscaling) 
        * **database**: relational databases (SQL) 
        * **nosql**: datastores other than RDBMS/SQL (often better in distributed environments) 
        * **messaging**: messaging systems, including Qpid, Apache MQ, RabbitMQ 
        * **monitoring**: monitoring tools, including Monit
        * **osgi**: OSGi servers 
        
* **brooklyn-docs**: the markdown source code for this documentation

* **brooklyn-dist**: projects for packaging Brooklyn and making it easier to consume
        * **all**: maven project to supply a shaded JAR (containing all dependencies) for convenience
        * **archetypes**: A maven archetype for easily generating the structure of new downstream projects
        * **dist**: builds brooklyn as a downloadable .zip and .tar.gz
        * **scripts**: various scripts useful for building, updating, etc. (see comments in the scripts)
