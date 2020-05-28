# Using Larger-Than-Default-Root EBS

The kernel used for EL 7 natively supports growing partitions hosted on the root disk at any time. This functionality requires that the AMI include the `cloud-utils-growpart` RPM. If the "`/`" filesystem is on either an unpartitioned disk or on a MBR- or GPT-style partition, the partition hosting the "`/`" will automatically be grown at first boot. However, this will _not_ occur if the "`/`" filesystem is hosted on an LVM2-managed volume. 

To create an instance with a root EBS larger than the AMI's default, use the following procedures:

1. Select a root EBS size larger than the AMI's default (if using the AWS console, do this under the "`Add Storage`" section of the AMI-launch wizard)
1. Launch the AMI
1. When the AMI completes its launch, login to the new instance
1. Escalate privileges to root
1. Issue the command "`/usr/bin/growpart /dev/xvda 2`"
1. Issue the command "`pvresize /dev/xvda2`"
1. Use the "`lvresize`" command to grow the volume(s)/filesystem(s) that need to be enlarged

Alternately, steps 5+ can be incorporated into the instance's UserData prior to launch. Something similar to the following should work:

~~~
#cloud-config
runcmd:
  - /usr/bin/growpart /dev/xvda 2
  - pvresize /dev/xvda2
  - lvresize -r -l 100%FREE VolGroup00/logVol
~~~

or

~~~
#cloud-config

growpart:
  mode: auto
  devices: [ '/dev/xvda2' ]
  ignore_growroot_disabled: false
~~~

or

~~~
#!/bin/bash
/usr/bin/growpart /dev/xvda 2
pvresize /dev/xvda2
lvresize -r -l 100%FREE VolGroup00/logVol
~~~

Note: _While this has not been extensively-tested to verify proper invocations_, if using a fifth-generation instance-types (`m5`, `c5`, etc.), it will likely be necessary to change occurrences of `xvda` to `nvme0n1`.
