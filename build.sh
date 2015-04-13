#!/bin/sh -e
DEVICE=$1
[ "$DEVICE" = "" ] && DEVICE=fenix3

monkeyc -o bin/HrWidget.prg -d $DEVICE -m manifest.xml -z resources/strings.xml:resources/bitmaps.xml:resources/menu/main.xml:resources/menu/period.xml src/HrWidget.mc
