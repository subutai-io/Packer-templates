#!/bin/bash

if [ -z "$BRANCHTAG" ]; then
  echo 'ERROR: $BRANCHTAG parameter not specified'
  exit -1
fi

DEBIAN_FRONTEND=noninteractive apt-get -q -y autoremove

# seems this is removing everything we install
#sudo dpkg -l 'linux-*' | sed '/^ii/!d;/'"$(uname -r | sed "s/\(.*\)-\([^0-9]\+\)/\1/")"'/d;s/^[^ ]* [^ ]* \([^ ]*\).*/\1/;/[0-9]/!d' | xargs sudo DEBIAN_FRONTEND=noninteractive apt-get -y purge

echo "cleaning up dhcp leases"
rm /var/lib/dhcp/*

echo "Remove the proxy configuration for local apt-cacher-ng setup"
if [ -f /etc/apt/apt.conf.d/02proxy ]; then
  rm -f /etc/apt/apt.conf.d/02proxy;
fi

echo "Replacing /etc/apt/sources.list with standard sources"
cp /tmp/sources.list /etc/apt/sources.list
DEBIAN_FRONTEND=noninteractive apt-get -q update

echo "Setting ulimit -n 65535 in /etc/profile"
sed -i '1 i\ulimit -n 65535' /etc/profile
