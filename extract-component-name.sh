#!/bin/bash

# Example run when there are no input
if [[ -z "$1" ]]; then
    INPUT="Multiple matches found.
hfkjdaf.fehwiu-fewagre-a.fewa/fdue/feuag98/hguesg/HELLO-here.fjkagjrw.ewag [id: 436526536]
3r4889gueg/fdsuaf/fhusg.fgr.esgres/lkpko.3fwagr.es. [id: 103249652]
090isre-4gg-ths-kpko.3fwagr.es.__. [id: 65463]"
else
    INPUT=$1
fi

list_of_results=()

# Pseudo code for the extract_component_name()
# 
# let list_of_results be empty list
# for line in multiline_string:
#     let A be equal to line
#     if / is found in A:
#         remove all the characters before the last / in A
#     if . is found in A:
#         remove all the characters after the first . in A
#     store A in list_of_results
# print list_of_results
list_of_results=()

while IFS= read -r line; do
    A="$line"
    [[ $A == */* ]] && A="${A##*/}"
    [[ $A == *.* ]] && A="${A%%.*}"
    list_of_results+=("$A")
done << EOF
$INPUT
EOF

for result in "${list_of_results[@]}"; do
    echo "$result"
done
