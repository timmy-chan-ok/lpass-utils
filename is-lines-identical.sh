#!/bin/bash

A=$(uniq -c << EOF 
$1
EOF
)

if [[ $A != *$'\n'* ]]; then
    echo "1"
else
    echo "0"
fi