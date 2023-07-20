#!/bin/bash

set -- "Multiple matches found.
Shared-secrets-okonomi-test/okonomi-ordre-api.test.jms.activemq.user [id: 1038559031490683608]
Shared-secrets-okonomi-test/okonomi-ordre-api.test.jms.activemq.user [id: 833227875220731710]"

id="1038559031490683608"

echo "$1" | grep "[id: 1038559031490683608]"

new_id=$(echo "$1" | grep -v "1038559031490683608" | grep -oP 'id: \K\d+')

echo New ID: "$new_id".
