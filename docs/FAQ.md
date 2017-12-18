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
    -   Red Hat 6
    -   CentOS 6
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


##### Footnotes:
------

<sup>1</sup>: The VMware image-maker is currently broken. It's on our task-list
to address. However, [community contributions](CONTRIBUTING.md) are always
welcome! :smile:

<sup>2</sup>: Currently (see [issue #87](https://github.com/plus3it/spel/issues/87)),
there are no VirtualBox builders for EL7. However,
[community contributions](../.github/CONTRIBUTING.md) are always welcome! :smile:
