#!/bin/sh -e
DEVICE=$1
[ "$DEVICE" = "" ] && DEVICE=fenix3

monkeyc -o bin/HrWidget.prg -d $DEVICE -m manifest.xml -z resources/strings.xml src/HrWidget.mc
