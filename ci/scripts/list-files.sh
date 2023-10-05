#!/bin/bash

for file in `find . -iname '*.prw' \
    -or -iname '*.prx' \
    -or -iname '*.tlpp' \
    -or -iname '*.prg' \
    -or -iname '*.apw' \
    -or -iname '*.aph' \
    -or -iname '*.tres' \
    -or -iname '*.png' \
    -or -iname '*.bmp' \
    -or -iname '*.res' \
    -or -iname '*.apl' \
    -or -iname '*.4gl' \
    -or -iname '*.per' \
    -or -iname '*.msg' \
    -or -iname '*.ahu'`; do
    echo -n "${file};"
done > sources.lst