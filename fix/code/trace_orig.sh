#!/bin/sh

for i in *.json
do
    echo "***"
    python ./exec_orig.py $i
    echo "  "
done
