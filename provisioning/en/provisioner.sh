#!/bin/bash

echo
echo '------------------------------------------------------------------'
echo 'User Specified Parameters:'
echo '------------------------------------------------------------------'
echo 'PROVISION                = '$PROVISION
echo 'SUBUTAI_PEER             = '$SUBUTAI_PEER
echo 'DESIRED_CONSOLE_PORT     = '$DESIRED_CONSOLE_PORT
echo 'DESIRED_SSH_PORT         = '$DESIRED_SSH_PORT
echo 'SUBUTAI_ENV              = '$SUBUTAI_ENV
echo 'SUBUTAI_RAM              = '$SUBUTAI_RAM
echo 'SUBUTAI_CPU              = '$SUBUTAI_CPU
#echo 'SUBUTAI_SNAP             = '$SUBUTAI_SNAP
echo 'SUBUTAI_DESKTOP          = '$SUBUTAI_DESKTOP
echo 'SUBUTAI_MAN_TMPL         = '$SUBUTAI_MAN_TMPL
echo 'APT_PROXY_URL            = '$APT_PROXY_URL
echo 'BRIDGE                   = '$BRIDGE
echo 'AUTHORIZED_KEYS          = '$AUTHORIZED_KEYS
echo
echo '------------------------------------------------------------------'
echo 'Run Generated Parameters:'
echo '------------------------------------------------------------------'
echo '_CONSOLE_PORT            = '$_CONSOLE_PORT
echo '_BRIDGED                 = '$_BRIDGED
echo '_BASE_MAC                = '$_BASE_MAC
#echo '_ALT_SNAP                = '$_ALT_SNAP
#echo '_ALT_SNAP_MD5            = '$_ALT_SNAP_MD5
#echo '_ALT_SNAP_MD5_LAST       = '$_ALT_SNAP_MD5_LAST
echo '_ALT_MANAGEMENT_MD5      = '$_ALT_MANAGEMENT_MD5
echo '_ALT_MANAGEMENT_MD5_LAST = '$_ALT_MANAGEMENT_MD5_LAST
echo '_ALT_MANAGEMENT          = '$_ALT_MANAGEMENT
echo

if [ "$PROVISION" = "false" ]; then
    echo Provisioning has been disabled, existing with SUCCESS
    exit 0;
fi

base="https://raw.githubusercontent.com/subutai-io/packer/no-snap/provisioning/en/"

wget --no-cache -O peer_cmd.sh $base/peer_cmd.sh >/dev/null 2>&1
wget --no-cache -O final_message.sh $base/final_message.sh >/dev/null 2>&1
wget --no-cache -O rhost_message.sh $base/rhost_message.sh >/dev/null 2>&1
wget --no-cache -O system_checks.sh $base/system_checks.sh >/dev/null 2>&1
wget --no-cache -O insecure.sh $base/insecure.sh >/dev/null 2>&1

chmod +x *.sh

case $SUBUTAI_ENV in
  sysnet)
    CMD="subutai-sysnet"
    ;;
  dev*)
    CMD="subutai-dev"
    ;;
  master)
    CMD="subutai-master"
    ;;
  prod*)
    CMD="subutai"
    ;;
  *)
    CMD="subutai"
esac

cmd_path="$(which $CMD)"

if [ -n "$cmd_path" -a ! -f "/home/subutai/subutai.zfs" ]; then
  echo "$CMD is installed"
  #snap refresh $CMD
elif [ -n "$cmd_path" -a  -f "/home/subutai/subutai.zfs" ]; then
  #echo "Unmounting and removing old zfs installation ..."
  #umount /var/lib/lxc
  #sudo snap remove $CMD

  # TODO: lots of code duplication here: func or file
  #echo "RE-provisioning custom snap ..."
  #snap install --dangerous /home/subutai/subutai.snap --devmode --beta
  #if [ $? -ne 0 ]; then
  #  >&2 echo "[ERROR] Custom snap installation failure. Aborting!"
  #  exit 1
  #elif [ -z "$(which $CMD)" ]; then
  #  installed_env="$(ls /snap | grep subutai | sed -e 's/subutai//g' -e 's/-//g')"
  #  specified_env="$(echo $CMD | sed -e 's/subutai//g' -e 's/-//g')"
    
  #  if [ "$installed_env" != "$specified_env" ]; then
  #    >&2 echo "[WARNING] The custom snap uses the $installed_env env but $specified_env was configured."
  #    >&2 echo "[WARNING] ADAPTING, BUT change subutai.yaml configs or reprovisioning will fail."
  #    CMD="$(ls /snap | grep subutai)"
  #  fi

  #  if [ -z "$(which $CMD)" ]; then
  #    >&2 echo "[ERROR] Cannot find $CMD executable after snap installation."
  #    >&2 echo "[ERROR] Exiting due to custom snap installation problems."
  #    exit 1
  #  fi
  #fi

  cmd_path="$(which $CMD)"
elif [ -f "/home/subutai/subutai.zfs" ]; then
  #echo "Provisioning custom snap ..."
  #snap install --dangerous /home/subutai/subutai.snap --devmode --beta
  #if [ $? -ne 0 ]; then
  #  >&2 echo "[ERROR] Custom snap installation failure. Aborting!"
  #  exit 1
  #elif [ -z "$(which $CMD)" ]; then
  #  installed_env="$(ls /snap | grep subutai | sed -e 's/subutai//g' -e 's/-//g')"
  #  specified_env="$(echo $CMD | sed -e 's/subutai//g' -e 's/-//g')"

  #  if [ "$installed_env" != "$specified_env" ]; then
  #    >&2 echo "[WARNING] The custom snap uses the $installed_env env but $specified_env was configured."
  #    >&2 echo "[WARNING] ADAPTING, BUT change subutai.yaml configs or reprovisioning may fail."
  #    CMD="$(ls /snap | grep subutai)"
  #  fi

  #  if [ -z "$(which $CMD)" ]; then
  #    >&2 echo "[ERROR] Cannot find $CMD executable after snap installation."
  #    >&2 echo "[ERROR] Exiting due to custom snap installation problems."
  #    exit 1
  #  fi
  #fi

  cmd_path="$(which $CMD)"
else
  echo "Installing $CMD ..."
  apt update && apt -y install subutai
  cmd_path="$(which $CMD)"
fi

if [ -z "$cmd_path" ]; then
  echo "[WARNING] $CMD installation failed aborting!"
  exit 1;
fi

#if [ -z "$(grep main-zfs /proc/mounts)" ]; then
#  echo "Mounting container storage ..."
#  /snap/$CMD/current/bin/btrfsinit /dev/mapper/main-btrfs -f #&> /dev/null
#  if [ $? -ne 0 ]; then exit 1; fi
#  sleep 2
#else
#  echo "Container storage already mounted."
#fi

if [ "$ALLOW_INSECURE" = true ]; then
  CMD=$CMD ./insecure.sh
  if [ $? -ne 0 ]; then exit 1; fi
fi

if [ "$SUBUTAI_PEER" = true ]; then
  CMD=$CMD ./peer_cmd.sh
  if [ $? -ne 0 ]; then exit 1; fi
else
  ./rhost_message.sh
fi

_CONSOLE_PORT=$_CONSOLE_PORT \
   _BRIDGED=$_BRIDGED ./final_message.sh

rm -f import.err *.sh
