#!/bin/sh

for i in *.json
do
    echo "***"
    python ./exec_oracle.py $i
    echo "  "
done
