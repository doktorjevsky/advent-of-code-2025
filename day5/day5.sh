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

    local current="" 
    local result
    while read low high || [ -n "$low" ]; do 
        result="$(merge_two_sorted_bounds $current $low $high)"
        if (( $(echo $result | wc -w) == 4 )); then 
            BOUNDS+=("$current")
            current="$low $high"
        else
            current=$result
        fi 

    done < $bounds_tmp
    BOUNDS+=("$current")

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

    if [[ -z "$A" ]]; then 
        echo "$a $b"
    fi 

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
    for bound in "${BOUNDS[@]}"; do 
        [ -n "$bound" ] && echo $bound
    done | awk '{result += $2 - $1 + 1} END {print result}' | prompt "PART 2:"

}


part_1()
{
    local id 
    local c=0
    for id in ${IDS[@]}; do 

        for bound in "${BOUNDS[@]}"; do 
            if is_fresh $id ${bound}; then 
                ((c++))
                break
            fi
        done 
        
    done
    echo "PART 1: $c"
}

main() (
    parse_input
    part_1
    part_2

)

(return 0 2>/dev/null) || time main "$@"
