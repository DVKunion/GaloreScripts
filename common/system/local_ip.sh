#! /bin/bash

machine_physics_net=$(ls /sys/class/net/ | grep -v "$(ls /sys/devices/virtual/net/)")
local_ip=$(ip addr | grep "$machine_physics_net" | awk '/^[0-9]+: / {}; /inet.*global/ {print gensub(/(.*)\/(.*)/, "\\1", "g", $2)}')
