#!/bin/bash

# Vagrant specific
date > /etc/vagrant_box_build_time

# Configure vagrant user
id vagrant 2>/dev/null || \
    ( useradd -m -r vagrant && echo "vagrant:vagrant" | chpasswd )

# Installing vagrant keys
echo "installing vagrant keys"
/bin/mkdir -pm 700 /home/vagrant/.ssh
/usr/bin/curl -s -S --retry 5 -L -o /home/vagrant/.ssh/authorized_keys https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
/bin/chown -R vagrant:vagrant /home/vagrant/.ssh
/bin/chmod 0600 /home/vagrant/.ssh/*

# Customize the message of the day
echo 'Development Environment' > /etc/motd
