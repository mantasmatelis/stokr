#!/bin/bash

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $DIR
osascript -e "do shell script \"/bin/bash openvpn-start.sh '$1' '$2'\" with administrator privileges"
