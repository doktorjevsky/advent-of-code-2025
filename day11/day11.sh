#!/bin/bash
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. $SCRIPTDIR/../utils/nicetohave.sh
if [ -z "$INPUT" ]; then 
    if [[ "$1" == "test" ]]; then 
        TEST=1
        shift
    else
        INPUT=${SCRIPTDIR}/input.txt
    fi 
fi

make_graph()
{
    local -n g="$1"
    while IFS=':' read a b || [ -n "$a" ]; do 
        g[$a]="${b:1:${#b}}" 
    done < "$INPUT"
}


# init MEM, GRAPH adn NODES before calling this function
count_paths() 
{ 
    RESULT=0
    local node="$1"
    local goal="$2"
    local mask="$3"
    local count i nbor result

    if [[ "$node" == "$goal" ]] && (( mask == 2**${#NODES[@]} - 1 )); then 
        RESULT=1
        return 
    
    elif [[ -v MEM["$node $mask"] ]]; then 
        RESULT=${MEM["$node $mask"]}
        return 
    fi 

    count=0
    new_mask=0
    for i in ${!NODES[@]}; do 
        [[ "${NODES[$i]}" == "$node" ]] && new_mask=$((new_mask + 2 ** $i))
    done 
    local old_mask=$mask
    mask=$((new_mask | mask))

    for nbor in ${GRAPH[$node]}; do 
        count_paths "$nbor" "$goal" "$mask"
        count=$((RESULT + count))
    done 

    MEM["$node $mask"]=$count
    RESULT=$count
}


part1()
{
    ((TEST)) && INPUT=${SCRIPTDIR}/test1.txt
    declare -A GRAPH
    declare -A MEM 
    RESULT=0
    TOTAL=0
    NODES=()
    make_graph GRAPH
    count_paths "you" "out" 0

    echo "PART 1: $RESULT"
}

part2()
{   

    ((TEST)) && INPUT=${SCRIPTDIR}/test2.txt
    declare -A GRAPH
    declare -A MEM 
    RESULT=0
    NODES=("fft" "dac")
    make_graph GRAPH
    count_paths "svr" "out" 0

    echo "PART 2: $RESULT"
  
}


main() (
    part1 
    part2
)

(return 0 2>/dev/null) || time main "$@"
