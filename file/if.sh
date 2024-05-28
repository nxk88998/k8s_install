#!/bin/bash

curl -ks  https://127.0.0.1:6443 > /dev/null
if [ $?  !=  "0" ]; then
exit 1
fi
