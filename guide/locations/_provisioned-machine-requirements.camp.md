    location:
      aws-ec2:us-east-1:
        identity: XXXXXXXX
        credential: XXXXXXXX
        waitForSshable: false
        pollForFirstReachableAddress: false
    services:
    - type: org.apache.brooklyn.entity.software.base.EmptySoftwareProcess
      brooklyn.config:
        onbox.base.dir.skipResolution: true
        sshMonitoring.enabled: false

