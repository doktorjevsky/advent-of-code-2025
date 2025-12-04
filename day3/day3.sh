#!/bin/bash
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ${SCRIPTDIR}/../utils/iterate.sh
. ${SCRIPTDIR}/../utils/nicetohave.sh

if [ -z "$INPUT" ]; then 
    if [[ "$1" == "test" ]]; then 
        INPUT="${SCRIPTDIR}/test.txt"
        shift
    else
        INPUT=${SCRIPTDIR}/input.txt
    fi 
fi

find_max_n_num_joltage()
{
    local n="$1" row num
    
    read -r row
    num=${row:0:$n}
    
    local i j contender new_num

    for ((i=$n; i < ${#row}; i++)); do 
        new_num="${num}${row:i:1}"

        for ((j=0; j < ${#new_num}; j++)); do

            contender="${new_num:0:$j}${new_num:$((j+1))}"
            
            if ((contender > num)); then 
                num=$contender
            fi
        done 

    done 

    echo $num
}

part()
{   
    local num 
    case "$1" in 
        1) num=2 ;;
        2) num=12 ;;
        *) echo "FATAL ERROR" >&2 && return 1 ;;
    esac
    while read -r line || [[ -n "$line" ]]; do 
        echo $line | find_max_n_num_joltage $num &
        if (( $(jobs -p | wc -l) >= 16 )); then 
            wait -n
        fi
    done < "$INPUT" | sum | prompt "PART $1: "
}

main() (
    
    part 1 &
    part 2

    wait
)

(return 0 2>/dev/null) || time main "$@"
