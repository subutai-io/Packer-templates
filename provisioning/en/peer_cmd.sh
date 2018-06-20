#!/bin/bash

/bin/cat <<EOM
Provisioning management capabilities (converting RH into peer)
This might take a little time ...
EOM

# Check ipfs swarm with peers
# timeout 5 min (300 sec)
NEXT_WAIT_TIME=10
# BEFORE sleep
sleep $NEXT_WAIT_TIME
until (export IPFS_PATH=/var/lib/ipfs/node && ipfs swarm peers > /dev/null) || [ $NEXT_WAIT_TIME -eq 300 ]; do
   echo "IPFS swarm with peers not ready"
   sleep 10
   NEXT_WAIT_TIME=$((NEXT_WAIT_TIME + 10))
done
# AFTER sleep
sleep 10

errcode=0
if [ -n "$(/usr/bin/$CMD list | grep management)" ]; then
  echo "Management seems to already be installed. Checking for upgrades..."
  /usr/bin/$CMD update management
  exit 0
else
  /usr/bin/$CMD import management 2> import.err
  errcode=$?
fi

if [ $errcode -ne 0 ]; then
  certificate="$(cat import.err | grep -e '.*x509.*certificate.*')"
  if [ -n "$certificate" ]; then
    echo "You're using a local CDN cache node with a self signed certificate."

    if [ "$CMD" != "subutai" ]; then
      echo "You're not using production so I'll enable insecure CDN downloads for you now."
      CMD=$CMD ./insecure.sh
      echo "Trying management import again ..."
      /usr/bin/$CMD import management
      errcode=$?
      if [ $errcode -ne 0 ]; then
        exit $errcode
      else
        rm -f import.err; touch import.err
      fi
    else
      echo "You must enable the allowInsecure property in the subutai.yaml file allow insecure CDN use."
      (>&2 cat import.err)
      exit $errcode
    fi
  fi

  (>&2 cat import.err)
  if [ $errcode -ne 0 ]; then exit $errcode; fi
fi

/bin/cat <<EOM

SUCCESS: Your peer is up. Welcome to the Horde!
-----------------------------------------------

Next steps ...
EOM
