#!/bin/sh -e
killall simulator || true
connectiq
./build.sh fenix3_sim
monkeydo bin/HrWidget.prg fenix3_sim
