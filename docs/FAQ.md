### Q: What OSes are currently supported?

A: The following OSes are supported via spel:

- RHEL 7
- CentOS 7
- RHEL 8
- CentOS 8-Stream
- Oracle Linux 8

Other ELx derivatives may work but have not been specifically tested.

### Q: Is RHEL or CentOS 8 Supported

A: Currently, three EL8 distros are explicitly supported

- Red Hat Enterpise Linux (RHEL) 8
- CentOSS 8 _Stream_
- Oracle Linux (OL) 8

The spel AMIs have a couple of design-dependencies: 

- Our primary development-platform is CentOS, not RHEL. Automation is written for CentOS, first. It is then ported and verified to work on RHEL. Finally (with the EL8+ release), it is ported and verified to work on OL.
- We try to make the Red Hat, CentOS and Oracle Linux images we publish as close to identical as their respective package repositories allow them to be. Until we have both the Red Hat _and_ CentOS.Org (and, now, Oracle Linux) flavors of a given release available, we don't update or extend our automation
- Because we try to provide a similar degree of AWS functionality to spel AMIs as is found in Amazon Linux AMIs, the spel AMIs require the ability to port the AWS utilities to RHEL and CentOS. Historically, the ability to so port has been contingent on EPEL-hosted packages.

Resultant of the above, we will not attempt support for EL8 until CentOS.Org has published a "final" AMI and until Fedora has made ("final") EPEL 8 repositories available. Status for both projects may be tracked at:

- CentOS 8 [build-status](https://wiki.centos.org/About/Building_8)
- EPEL 8 [support-status](https://fedoraproject.org/wiki/EPEL#What_packages_and_versions_are_available_in_EPEL.3F)

Notes:
1. EPEL dependency is AWS-only
2. EPEL dependency may be removed in later ELx versions as baked-in packages' dependencies permit

Note: Initial functionality for any given ELx build orchestrated by spel starts with an AMIgen project. Functionality for EL8 will be trackable within the [AMIgen8 project](/plus3it/AMIgen8).

### Q: What happened to support for EL6?

A: Red Hat Enterprise Linux 6 is in the last stages of the standard support-lifecycle's de-support phase. This support-lifecycle reaches its conclusion on November 30, 2020. Down-stream projects' &mdash; such as CentOS 6 &mdash; will conclude _their_ support-lifecycle in a similar time-frame. Further, our primary customer-base had begun the process of moving their solution-stacks to later ELx releases in October of 2018. Therefore, due to the pending demise of both EL6 and our primary customers' need for updated EL6 AMIs, we chose to cease publishing new EL6 images or testing spel functionality against el6 with the October 16<sup>th</sup>, 2018 AMI.

While it's possible that this automation can continue to be used to create new EL6 AMIs, we will not be continuing to test that functionality or publishing new EL6 AMIs

### Q: Are the images STIG-hardened?

A: No. The only STIG-related hardening is:

-   The images' root device is pre-partitioned to allow the various
    "`${DIRECTORY}` must be on its own filesystem" scan-tests to pass
-   Red Hat and CentOS 7.x images are FIPS-enabled

### Q: Why aren't the images STIG-hardened?

A. As of the writing of this FAQ answer:

-   Images are published in the following repositories
    -   Amazon Machine Image in AWS commercial region us-east-1
    -   Amazon Machine Image in AWS commercial region us-east-2
    -   Amazon Machine Image in AWS commercial region us-west-1
    -   Amazon Machine Image in AWS commercial region us-west-2
    -   Amazon Machine Image in AWS GovCloud region us-gov-west-1
    -   VirtualBox image in [Vagrant Cloud](https://vagrantcloud.com/)
    -   VMware image in Vagrant Cloud<sup>1</sup>
-   Proliferations for each of the above repositories exist for
    -   Red Hat 7<sup>2</sup>
    -   CentOS 7<sup>2</sup>
-   Images are produced monthly. This means maintaining 28 images per month for
    a minimum time-span of six to twelve months.

Additionally, the STIG contents contain multiple scanning/hardening profiles.
To support each profile would require a unique, pre-hardened image for each
"off the shelf" profile. This does not account for custom scanning/hardening
profiles. Supporting _all_ of the "off the shelf" profiles via pre-hardened
images would require generating 100+ images per month. Not practical on a
monthly basis; even less practical when extended across the six- to twelve-month
lifespan of images in multiple deployment domains (i.e., AWS, Vagrant Cloud...
and eventually Azure and possibly others).

Because of the above, we opted to keep AMIs as minimally-hardened as possible -
instead choosing to apply hardenings at launch-time using other frameworks.

### Q: So... Why would I use these images, then?

In general, once an image is launched as a VM, it requires considerable
gymnastics to re-layout the storage to meet STIG requirements. Those gymnastics
can vary from simply annoyingly labor-intensive to effectively "not possible".
This set of images solves that problem.

Similarly - relevant to EL7 images - attempting to enable FIPS at launch-time
requires sorting out how to automate launch-time provisioning processes across
multiple boots. While possible, it introduces gymnastics many would-be-users
don't want to have to sort out. This set of images avoids that problem.

### Q: Alright... Any suggestions for launching a hardened VM?

A. Many of our images' users leverage in-house build-workflows to handle
initial provisioning of image-sourced instances. They use things like Chef,
Puppet, Ansible, etc. Users that have no such in-house build-workflows, we
typically recommend our launch-driver,
[Watchmaker](https://github.com/plus3it/watchmaker.git).

### Q. Watchmaker looks promising: how do I use it?

A. This FAQ is for using spel. That said Watchmaker includes a full
[documentation set](https://watchmaker.readthedocs.io) that should help you
with its use.


### Q. My application won't work under FIPS: now what?

A. If you're using EL6 images, this is a non-problem. If you're using EL7,
things are a bit more challenging. Our images are FIPS-enabled because the
STIGs say they need to be. As such, our users ultimately need to figure out how
to get their app to work under FIPS or get an exception from their security
team (sorta like firewalld and SELinux - also baked in to the EL7 images).
These images are meant as a 90% solution. If you're one of the unlucky 10%
whose app won't work under FIPS in EL7, the best we can suggest is to let your
provisioning framework handle the problem for you.

### Q. But I'm following your suggestion to use Watchmaker: can that help me with toggling FIPS mode?

A. Yes. See watchmaker's [documentation](https://watchmaker.readthedocs.io/en/stable/faq.html)
for guidance.

### Q. The root volume-group and its partitions seem too small for my use-case: is there any way I can un-handcuff myself from the current partitioning-scheme?

A. Yes. The methods for doing so are dependent on EL version and deployment-contexts. As of this writing, we have documented how to deploy a VM using a root device that is larger than the templated default:

* [spel for EL7 on AWS](LargerThanDefaultRootEBS_EL7.md)
* spel for EL8 on AWS: see the previously-linked EL7 document &ndash; the methods are the same

Procedures for other deployment-contexts are not core to this project. Therefore, they have not been documented. Please feel free to experiment and [contribute](CONTRIBUTING.md)!

It is generally expected that if users need to grow an _existing_ instance's root volume group that they reprovision and follow the above linked-to documents. If reprovisioning is not practical, the next best option is to add a secondary drive to the VM and expand the root volume group onto the secondary drive.


##### Footnotes:
------

<sup>1</sup>: The VMware image-maker is currently broken. It's on our task-list
to address. However, [community contributions](CONTRIBUTING.md) are always
welcome! :smile:

<sup>2</sup>: Currently (see [issue #87](https://github.com/plus3it/spel/issues/87)),
there are no VirtualBox builders for EL7. However,
[community contributions](../.github/CONTRIBUTING.md) are always welcome! :smile:
