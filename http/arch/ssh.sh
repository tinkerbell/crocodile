#!/usr/bin/env bash

PASSWORD=$(/usr/bin/openssl passwd -crypt 'tinkerbell')

# Tinkerbell configuration
/usr/bin/useradd --password ${PASSWORD} --comment 'Tinkerbell User' --create-home --user-group tinkerbell
echo 'Defaults env_keep += "SSH_AUTH_SOCK"' > /etc/sudoers.d/10_tinkerbell
echo 'tinkerbell ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers.d/10_tinkerbell
/usr/bin/chmod 0440 /etc/sudoers.d/10_tinkerbell
/usr/bin/systemctl start sshd.service
