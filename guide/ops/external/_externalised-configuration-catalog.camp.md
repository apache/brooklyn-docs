The same blueprint language DSL can be used within YAML catalog items. For example:

    brooklyn.catalog:
      id: com.example.myblueprint
      version: "1.2.3"
      itemType: entity
      brooklyn.libraries:
      - >
        $brooklyn:formatString("https://%s:%s@repo.example.com/libs/myblueprint-1.2.3.jar", 
        external("mysupplier", "username"), external("mysupplier", "password"))
      item:
        type: com.example.MyBlueprint

Note the `>` in the example above is used to split across multiple lines.
