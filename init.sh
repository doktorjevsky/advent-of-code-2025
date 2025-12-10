#!/bin/bash

SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

NEXT_DAY="$((1 + $(ls ${SCRIPTDIR}/day* | grep -Eo "[0-9]+" | sort | tail -n 1)))"
NEXT_DAY_DIR="${SCRIPTDIR}/day${NEXT_DAY}"
NEXT_DAY_SCRIPT="${NEXT_DAY_DIR}/day${NEXT_DAY}.sh"

mkdir -p $NEXT_DAY_DIR
! [ -e ${NEXT_DAY_SCRIPT} ] && cat << 'EOF' > ${NEXT_DAY_SCRIPT}
#!/bin/bash
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [ -z "$INPUT" ]; then 
    if [[ "$1" == "test" ]]; then 
        INPUT="${SCRIPTDIR}/test.txt"
        shift
    else
        INPUT=${SCRIPTDIR}/input.txt
    fi 
fi

part1()
{
    echo "This is part 1!"
}

part2()
{
    echo "This is part 2!"
}

main() (
    part1
    part2
)

(return 0 2>/dev/null) || time main "$@"
EOF

chmod +x ${NEXT_DAY_SCRIPT}
! [ -e ${NEXT_DAY_DIR}/input.txt ] && touch ${NEXT_DAY_DIR}/input.txt
! [ -e ${NEXT_DAY_DIR}/test.txt ] && touch ${NEXT_DAY_DIR}/test.txt
