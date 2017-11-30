# How to contribute

This project originated as an engine for driving the [AMIgen6](https://github.com/ferricoxide/AMIgen6.git) and [AMIgen7](https://github.com/ferricoxide/AMIgen7.git) tool-sets. The initial objective was to ease and speed the creation of AWS AMIs with these AMIs so that the task:
- could be turned over to less-experienced staff
- increase the velocity of AMI-releases
- increase the AMI release-proliferation (addition of RHEL to the original CentOS-focused releases)
- increase the number of AWS regions supported (from just us-east-1 to all of the CONUS regions - including GovCloud)

Since then, the objective has been expanded to include:
- generation of VirtualBox images
- generation of VMware templates
- generation of Azure images
- publishing of VirtualBox and VMware images to Vagrant Cloud
Where all of the above images are notionally-identical but for their respective deployment contexts. "Notionally-identical" also means that produced Red Hat and CentOS images' RPM-manifests and storage-layouts are the same within a given release-cycle.

The fruits of this automation-effort are openly provided on an "as-is" basis. Individuals who have stumbled on this project and find deficiencies in it are invited to help us enhance the project for broader usability. This can be done by opening issues against the project or, even better, offering enhancements via Pull Requests:
* Please open an issue to identify "missing" deployment contexts
* Please open pull requests - referencing the previously-opened issue - when ready to provide automation for new contexts.


## Testing

To be written...

## Submitting Changes

Please send a GitHub Pull Request with a clear list of what changes are being offered (read more about [pull requests](http://help.github.com/pull-requests/)).

Please ensure that the commits bundled in the PR are performed with clear and concise commit messages. One-line messages are fine for small changes, but bigger changes should look like this:

    $ git commit -m "A brief summary of the commit
    > 
    > A paragraph describing what changed and its impact."

## Coding conventions

To be written...

    * Anything not otherwise specified - either explicitly as above or implicitly via pre-existing code - pick an element-style and be consistent with it .


## Additonal Notes

To be written...
