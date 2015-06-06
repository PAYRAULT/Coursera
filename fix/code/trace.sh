#!/bin/sh

for i in *.json
do
    echo "***"
    python ./exec.py $i
    echo "  "
done
