#!/bin/bash

# Get the directory of the current script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

"$DIR/create.sh"
"$DIR/firewall.sh"
"$DIR/transfer.sh"
"$DIR/up.sh"
