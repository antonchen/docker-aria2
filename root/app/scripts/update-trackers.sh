#!/bin/bash
# Author: Anton Chen <contact@antonchen.com>
# Create Date: 2019-04-17 22:19:38
# Last Modified: 2019-04-17 22:20:04
# Description: 
Conf="/config/aria2.conf"
Trackers="$(curl -s https://raw.githubusercontent.com/XIU2/TrackersListCollection/master/all.txt|awk NF|sed ':a;N;s/\n/,/g;ta')"

if [ "x$Trackers" == "x" ]; then
    exit
fi

grep -q "bt-tracker" $Conf
if [ $? -ne 0 ]; then
    echo "bt-tracker=$Trackers" >> $Conf
else
    sed -i "s@bt-tracker.*@bt-tracker=$Trackers@g" $Conf
fi

pkill -15 aria2c
