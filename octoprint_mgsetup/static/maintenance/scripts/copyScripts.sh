#!/bin/sh
echo "Copying maintenance scripts to OctoPrint"
cp /home/pi/oprint/lib/python3.7/site-packages/octoprint_mgsetup/static/maintenance/gcode/*  /home/pi/.octoprint/scripts/gcode
sleep 3.5
echo "Maintenance scripts are now ready!"
