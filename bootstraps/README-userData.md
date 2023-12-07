The `builder-userData.mixed` file is built to allow the injection of key data
into a userData payload. To leverage this userdata, execute a launch similarly
to the following:

~~~
aws ec2 run-instances \
  --image-id <BOOTSTRAP_AMI>\
  --instance-type <INSTANCE_TYPE> \
  --key-name <KEY_NAME> \
  --security-group-ids <SECURITY_GROUPS>\
  --subnet-id <SUBNET_ID>\
  --tag-specifications 'ResourceType=instance,Tags=[{
    Key=Name,Value=Packer Chroot-Builder
  }]' \
  --user-data file:///<(
    sed -e 's#SOURCE_SUBST#https://github.com/plus3it/AMIgen9.git#' \
        -e 's#BRANCH_SUBST#main#'
      builder-userData.mixed
  ) \
  --query 'Instances[].InstanceId'
~~~
