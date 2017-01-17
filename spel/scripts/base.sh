#!/bin/bash

# Setup repos
echo "installing the epel repo"
yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm >/dev/null

# Update the box
echo "installing updates"
yum clean all >/dev/null
bash /tmp/retry.sh 5 yum -y update >/dev/null

# Install common deps
echo "installing common dependencies"
bash /tmp/retry.sh 5 yum -y install virt-what unzip >/dev/null

# Tweak sshd to prevent DNS resolution (speed up logins)
echo "disabling dns resolution in sshd"
grep -q '^UseDNS' /etc/ssh/sshd_config && \
    sed -i -e \
    's/^UseDNS.*/UseDNS no/' \
    /etc/ssh/sshd_config || \
    sed -i "$ a\UseDNS no" /etc/ssh/sshd_config
