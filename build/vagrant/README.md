# spel-vagrant

Project that allows for a vagrant box to be created using the SPEL AMI. Specifically, this project creates a 'metal' box within AWS, installs the virtualization tools, and creates a vagrant box.

# environment variables

There are a number of environment variables that are needed within the CodeBuild job for it to execute successfully
* AWS_REGION
* SSM_VAGRANTCLOUD_TOKEN - the path to the SSM parameter that is holding your vagrantcloud token
* VAGRANTCLOUD_USER - your vagrantcloud username
* SPEL_IDENTIFIER
* SPEL_VERSION - the version of SPEL that is being released
* TERRAFORM_VERSION - the version of terraform to use
* PACKER_VERSION - the version of packer to use
* KMS_KEY - the AWS KMS Key used to decrtyp the SSM parameter
