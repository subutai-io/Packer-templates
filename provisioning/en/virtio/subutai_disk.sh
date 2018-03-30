#!/usr/bin/env bash

result=`lsblk -o SIZE,NAME --bytes | grep "$((1073741824*(DISK_SIZE+2)))" | tail -1`
disk_name=`expr match "$result" '.*\([v][d][b-z]*\)'`

disk="/dev/${disk_name}"

sudo pvcreate "$disk"
sudo vgextend main "$disk"
sudo lvextend -L+$(($DISK_SIZE+1))'G' /dev/mapper/main-btrfs

which btrfs

if [ $? != 0 ]; then
  sudo apt -y install btrfs-tools
fi

sudo btrfs filesystem resize +$DISK_SIZE'g' /var/snap/subutai*/common/lxc