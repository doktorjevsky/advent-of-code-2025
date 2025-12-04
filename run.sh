#!/bin/bash

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

case "$1" in 
    [0-9]|[1-2][0-9])
        ARG="$1"
        shift
        "${SCRIPTDIR}/day${ARG}/day${ARG}.sh" "$@"
    ;;
    *)
        echo "ERROR! bad arg: $1"
    ;;
esac