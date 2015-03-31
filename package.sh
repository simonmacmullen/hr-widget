#!/bin/sh
monkeyc -e \
    -o bin/HrWidget.iq \
    -w \
    -z resources/strings.xml:resources/bitmaps.xml \
    -m manifest.xml \
    src/HrWidget.mc
