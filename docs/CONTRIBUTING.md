# How to contribute

This project originated as an engine for driving the [AMIgen6](https://github.com/ferricoxide/AMIgen6.git) and [AMIgen7](https://github.com/ferricoxide/AMIgen7.git) tool-sets. The initial objective was to ease and speed the creation of AWS AMIs so that the task:

* could be turned over to less-experienced staff
* increase the velocity of AMI-releases
* increase the AMI release-proliferations (addition of RHEL to the original CentOS-focused releases)
* increase the number of AWS regions supported (from just us-east-1 to all of the CONUS regions - including GovCloud)

Since then, the objective has been expanded to include:

* generation of VirtualBox images
* generation of VMware templates
* generation of Azure images
* generation of OpenStack images
* publishing of VirtualBox and VMware images to Vagrant Cloud

Where all of the above images are notionally-identical but for their respective deployment contexts. "Notionally-identical" also means that produced Red Hat and CentOS images' RPM-manifests and storage-layouts are the same within a given release-cycle.

The fruits of this automation-effort are openly provided on an "as-is" basis. Individuals who have stumbled on this project and find deficiencies in it are invited to help us enhance the project for broader usability. This can be done by opening issues against the project or, even better, offering enhancements via Pull Requests:

* Please open an issue to identify "missing" deployment contexts
* Please open pull requests - referencing the previously-opened issue - when ready to provide automation for new contexts.


## Testing

In progress...

Currently, this project links to a couple of services. When submitting a PR:
* Basic lints will be performed against any shell script
* Basic lints will be performed against any Packer templates
* Offered content will be tested by a CodeCommit pipeline that ensures that modifications continue to produce functional AMIs
* Documentation will be tested for recency.
    Note: if the associated Travis CI job fails with a message like:
    ~~~
    Error: spel/README.md is out of date
    make: *** [/home/travis/build/plus3it/spel/tardigrade-ci/Makefile:463: docs/lint/spel/README.md] Error 1
    The command "make -f Makefile.tardigrade-ci lint" exited with 2.
    ~~~
    It will be necesary to execute:
    ~~~
    make -f Makefile.tardigrade-ci docs/generate
    ~~~
    In your branch's project-root (and then commit any changes) in order to clear it.




## Building and Releasing AMIs

The [Build images](../.github/workflows/build.yml) workflow builds the AMIs. It
runs monthly on a schedule, on a PR review containing `/build`, or on demand
with `workflow_dispatch`. Each platform and partition is a separate job, that:

1. Builds a private AMI in the build region of the CodeBuild project
2. Tests the AMI, and tags it `spel:validated=true` if the tests pass. If the
    tests fail, the AMI is deregistered
3. Copies the AMI to `AMI_REGIONS`, and shares it with `AMI_GROUPS` in every
    region. Sharing is done last, so a failure leaves the AMI private
4. Deletes the AMI instead, when `SPEL_CI` is `true`

The scheduled build then creates the release PR. If any job failed, the PR is a
draft that includes the images that succeeded.

Every step checks the state of the AMI in AWS first, so jobs can be re-run
safely. A validated or published AMI is not rebuilt, a failed AMI is replaced,
and a partial copy resumes.

### Retrying a failed build

* **Transient failure**: Use "Re-run failed jobs". Only the failed jobs run
  again, and the release PR is updated and marked ready when all jobs succeed.
* **Fix required**: Open a separate PR with the fix, in the project that needs
  it, and merge it. Do not commit the fix to the release PR. The workflow
  recreates the release branch from `master` on every run, and never builds
  from it. How to pick up the fix depends on where it was merged:
  * **amigen8 or amigen9**: The build clones the amigen branch (`master` for
    amigen8, `main` for amigen9) when it runs. After the fix merges, use
    "Re-run failed jobs".
  * **spel**: A re-run uses the spel commit of the original run, so it does
    not include the fix. After the fix merges to `master`, run the workflow
    from `master` with `workflow_dispatch`, using the same `SPEL_VERSION`,
    `SPEL_CI=false`, and `SPEL_RELEASE=true`. Set `SPEL_BUILDERS` to the
    failed builds, or leave the default to run all builds and skip the ones
    that are done. The existing release PR is updated.
* **Rebuild a validated, unpublished AMI**: Set `SPEL_FORCE=true`. This does not
  replace a published AMI.

### Removing a published AMI

Run the [Deregister images](../.github/workflows/deregister.yml) workflow with
the `SPEL_VERSION` and `SPEL_BUILDERS` to remove. It deregisters the AMIs and
their snapshots from every region. Set `SPEL_DEREGISTER_PUBLIC=true` to remove
public AMIs. The images can then be rebuilt as described above.

## Submitting Changes

Please send a GitHub Pull Request with a clear list of what changes are being offered (read more about [pull requests](http://help.github.com/pull-requests/)).

Please ensure that the commits bundled in the PR are performed with clear and concise commit messages. One-line messages are fine for small changes, but bigger changes should look like this:

    $ git commit -m "A brief summary of the commit
    > 
    > A paragraph describing what changed and its impact."

Also: even if the PR doesn't otherwise include documentation-updates, ensure that the project's documentation adequately up to date. Run `make docs/generate` in the project-root. Typically, this will only update the top-level README. 

Note: Depending how old your branch is, it may also be necessary to run `make terraform-docs/install` before running `make docs/generate`. If running `make docs/generate` doesn't result in `git` seeing an updated README, update your terraform-docs module.

## Coding conventions

To be written...

* Anything not otherwise specified - either explicitly as above or implicitly via pre-existing code - pick an element-style and be consistent with it .


## Additonal Notes

To be written...
