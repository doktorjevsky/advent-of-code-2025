#!/bin/bash
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ${SCRIPTDIR}/../utils/nicetohave.sh

if [ -z "$INPUT" ]; then 
    if [[ "$1" == "test" ]]; then 
        INPUT="${SCRIPTDIR}/test.txt"
        shift
    else
        INPUT=${SCRIPTDIR}/input.txt
    fi 
fi


parse_input()
{
    BOUNDS=()
    IDS=()
    local bounds_tmp=$(mktemp)

    {
        while IFS='-' read -r low high && [ -n "$low" ]; do 
            echo "$low $high" >> $bounds_tmp
        done

        while read -r line || [ -n "$line" ]; do 
            IDS+=("$line")
        done 

    } < "$INPUT"

    sort -n -k1,1 -k2,2 $bounds_tmp -o $bounds_tmp

    while read low high || [ -n "$low" ]; do 

        BOUNDS+=("$low $high")

    done < $bounds_tmp

    rm $bounds_tmp

    
}

is_fresh()
{
    local id="$1"
    local a="$2"
    local b="$3"
    (( a <= id && id <= b ))
}

merge_two_sorted_bounds()
{
    local a="$1"
    local b="$2"
    local A="$3"
    local B="$4"


    if (( A - b == 1)); then 
        echo "$a $B"

    # a b A B
    elif (( b < A )); then
        echo "$@"

    # a A b B
    else (( (a <= A && b <= B) )) 
        echo "$(min $a $A) $(max $b $B)"

    fi

}


part_2()
{
    {
        local current="${BOUNDS[0]}"
        local new_bounds
        local i result
        for ((i=1; i < ${#BOUNDS[@]}; i++)); do 
            result="$(merge_two_sorted_bounds $current ${BOUNDS[$i]})"
            if (( $(echo $result | wc -w) == 4 )); then 
                echo $current
                current="${BOUNDS[$i]}"
            else
                current=$result
            fi 
        done 
        echo $current
    } | awk '{result += $2 - $1 + 1} END {print result}' | prompt "PART 2: "

}


part_1()
{
    local id
    for id in ${IDS[@]}; do 
        (
            for bound in "${BOUNDS[@]}"; do 
                is_fresh $id ${bound} && echo 1 && break
            done 
        ) & 
        (( $(jobs -r | wc -l) >= $(nproc) )) && wait -n
    done | sum | prompt "PART 1: "
}

main() (
    parse_input
    part_1
    part_2
)

(return 0 2>/dev/null) || time main "$@"
