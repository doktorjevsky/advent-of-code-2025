#!/bin/bash
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
[ -z "$INPUT" ] && INPUT=${SCRIPTDIR}/input.txt

main() (
    echo "Hello world!"
)

(return 0 2>/dev/null) || time main "$@"
