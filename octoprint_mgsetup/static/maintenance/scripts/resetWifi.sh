#!/bin/sh

echo "Resetting network settings and restarting printer"
sudo netconnectcli forget_wifi
netconnectcli stop_ap
echo "Netconnectd Wifi forgotten!"
echo "Restarting"

sudo shutdown -r now
