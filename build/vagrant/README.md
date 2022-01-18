# spel-vagrant

Project that allows for a vagrant box to be created using the SPEL AMI. Specifically, this project creates a 'metal' box within AWS, installs the virtualization tools, and creates a vagrant box.

# environment variables

There are a number of environment variables that are needed within the CodeBuild job for it to execute successfully

* AWS_REGION
* SPEL_IDENTIFIER - namespace for the image
* SPEL_VERSION - version for the image
* VAGRANT_CLOUD_TOKEN - token with write permission to the vagrant cloud account
