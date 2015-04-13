#!/bin/sh
MODE=$1
[ "$MODE" = "" ] && MODE=widget

RESOURCE_PATH=$(find . -path './resources*.xml' | xargs | tr ' ' ':')

monkeyc -e \
    -o bin/hr-$MODE.iq \
    -w \
    -z $RESOURCE_PATH \
    -m manifest-$MODE.xml \
    src/*.mc
