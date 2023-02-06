#!/bin/bash
##########################################################################
# SOMA Installer - Small Office Media Appliance
# Feedback and support please directly on github on the project site
# https://github.com/Moondog8862/soma-media-server
# Thanks, Adrian a.schmid@pm.me
##########################################################################
CP=/bin/cp
MKDIR=/bin/mkdir

# File locations
SOMA_BASE=/var/lib/soma
LOGFILE=$SOMA_BASE/log-tvheadend-checkdvb.log

# Debug command
#chown -R root.root /dev/dvb/adapter0
dvbpath=/dev/dvb/adapter0
dvbgroup=$(ls -ld /dev/dvb/adapter0 | awk '{print $4}')
dvbuser=$(ls -ld /dev/dvb/adapter0 | awk '{print $4}')
tvhbin=/usr/local/bin/tvheadend

sleep 10

echo "------------- CHECKDVB LOG START ------------" >> $LOGFILE
echo $(/bin/date) >> $LOGFILE

# check existence of the adapter directory
[ -d "$dvbpath" ] && E="The dvb directory exists" || E="The dvb directory does NOT exist -- waiting" waiting=1
echo "$E" >> $LOGFILE
[ "$waiting" == "1" ] && sleep 10

# check existence of the adapter directory
#[ -d "$dvbpath" ] && E="The dvb directory exists" || E="The dvb directory does NOT exist -- exiting" exitnow=1
#echo "$E" >> $LOGFILE
#[ "$exitnow" == "1" ] && exit

# changing permissions
echo "Current user: "$dvbuser >> $LOGFILE
[ "$dvbuser" != "hts" ] && F="The path is now configured for user hts" chown -R hts $dvbpath || F="The path is already configured for user hts"
#chown -R root.video $dvbpath
echo "$F" >> $LOGFILE

echo "Current group: "$dvbgroup >> $LOGFILE
[ "$dvbgroup" != "video" ] && F="The path is now configured for group video" chgrp -R video $dvbpath || F="The path is already configured for group VIDEO"
#chown -R root.video $dvbpath
echo "$F" >> $LOGFILE

# Note: recording directory MUST be inside the /home/hts folder
chown -R hts.video /home/hts/feni/dvbrecorder
chown -R hts.video /home/hts/.hts

# Restarting tvheadend for changes to take effect
process=$(ps -e | grep tvheadend | awk '{print $4}')
echo "Process before stop: "$process >> $LOGFILE
#/etc/init.d/tvheadend stop
killall tvheadend
sleep 10
process=$(ps -e | grep tvheadend | awk '{print $4}')
echo "Process before start: "$process >> $LOGFILE
#/etc/init.d/tvheadend start
$tvhbin -c /home/hts/.hts/tvheadend &
#$tvhbin -u hts -g dvbgroup -c /home/hts/.hts/tvheadend &
process=$(ps -e | grep tvheadend | awk '{print $4}')
echo "Process after start: "$process >> $LOGFILE
ls -ld $dvbpath >> $LOGFILE
echo "Debugging output written to "$LOGFILE

echo "showing last 60 lines from logfile"
tail $LOGFILE

# Start Kodi
#sleep 15
#echo "Now starting kodi..." >> $LOGFILE
#NAME=kodi
#DAEMON=/usr/bin/$NAME
#/usr/bin/kodi &
#/usr/bin/kodi-standalone &
#/sbin/start-stop-daemon -o --start \
#  -u "USER" -g "GROUP" --chuid "USER:GROUP" -b --exec "$DAEMON"

