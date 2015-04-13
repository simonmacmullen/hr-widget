#!/bin/sh -e
DEVICE=$1
[ "$DEVICE" = "" ] && DEVICE=fenix3
MODE=$2
[ "$MODE" = "" ] && MODE=widget

RESOURCE_PATH=$(find . -path './resources*.xml' | xargs | tr ' ' ':')
monkeyc -o bin/hr-$MODE.prg -d $DEVICE -m manifest-$MODE.xml -z $RESOURCE_PATH src/*.mc
