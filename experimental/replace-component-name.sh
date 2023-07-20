#!/bin/bash

if [[ -z "$1" ]]; then
    read -p "Hva er pathen til lastpass secret som skal endres? " LASTPASS_PATH_ORIGINAL
else
    LASTPASS_PATH_ORIGINAL=$1
fi

if [[ -z "$2" ]]; then
    read -p "Hva er IDen til lastpass secret som skal endres? " LASTPASS_ID_ORIGINAL
else
    LASTPASS_ID_ORIGINAL=$2
fi

if [[ -z "$3" ]]; then
    read -p "Hva er det nye komponent-navnet? " KOMPONENT_NAVN_2
else
    KOMPONENT_NAVN_2=$3
fi

A="$LASTPASS_PATH_ORIGINAL"
[[ $A == */* ]] && A1="${A%/*}"
[[ $A == */* ]] && A="${A##*/}"
[[ $A == *.* ]] && A3="${A#*.}"
[[ $A == *.* ]] && A="${A%%.*}"
A2="$A"

# WARN: Antar at A1 og A3 existerer
LASTPASS_PATH_NEW="$A1/$KOMPONENT_NAVN_2.$A3"
echo "Original: $LASTPASS_PATH_ORIGINAL"
echo "New     : $A1/$KOMPONENT_NAVN_2.$A3"

# Endrer navn på lastpass secret
echo "$LASTPASS_PATH_NEW" | lpass edit --non-interactive --sync=no --name "$LASTPASS_ID_ORIGINAL"

echo "done"