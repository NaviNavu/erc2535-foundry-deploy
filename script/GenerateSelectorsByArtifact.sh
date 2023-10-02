#!/bin/sh

if [ "$#" -ne 1 ]; then
    echo "Usage: script/GenerateSelectorsByArtifact.sh <facet_name> ">&2
    exit 1
fi

if [ -e ./out/$@.sol/$@.json ]
then
    cast abi-encode "f(bytes4[])" "$(jq -r '.methodIdentifiers | join(",") | "[" + . + "]"' ./out/$@.sol/$@.json)"
else
    echo "Artifact not found">&2
    exit 1
fi

exit 0
