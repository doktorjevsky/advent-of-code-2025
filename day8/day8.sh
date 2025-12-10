#!/bin/bash
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ -z "$INPUT" ]; then 
    if [[ "$1" == "test" ]]; then 
        COUNT=10
        INPUT="${SCRIPTDIR}/test.txt"
        shift
    else
        COUNT=1000
        INPUT=${SCRIPTDIR}/input.txt
    fi 
fi


dist3_sqr()
{
    local X=$(( $1 - $4 ))
    local Y=$(( $2 - $5 ))
    local Z=$(( $3 - $6 ))

    echo $(($X * $X + $Y * $Y + $Z * $Z))
}

set_input()
{
    sed -i 's|,| |g' $INPUT
}

pair_points()
{
    POINT_PAIRS=${SCRIPTDIR}/point_pairs.txt
    echo -n > $POINT_PAIRS
    mapfile -t POINTS < "$INPUT"
    local tmp=$(mktemp -d)
    local i j dist new_dist closest_point_idx
    local N=${#POINTS[@]}
    local maxprocs=$(nproc)
    for ((i=0; i < $N; i++)); do 
        {
            local j
            for ((j=$i; j < $N; j++)); do 
                if (( i != j )); then 
                    
                    echo "${POINTS[$i]},${POINTS[$j]},$(dist3_sqr ${POINTS[$i]} ${POINTS[$j]})"
                fi 
            done 
        } > ${tmp}/${i} &

        (( $(jobs -r | wc -l ) >= maxprocs )) && wait -n
        
    done 
    
    wait
    cat ${tmp}/* | sort -n -t ',' -k 3 -o $POINT_PAIRS
    rm -r $tmp
}

print_part_1()
{
    printf "%s\n" "$@" | 
    sort -n       |
    uniq -c       |
    sort -rn -k 1 |
    head -n 3     |
    awk 'BEGIN {r = 1} { r *= $1 } END {print "PART 1: " r}'
    
}

make_circuits() {
    declare -A CIRCUITS
    local next_circuit=0
    local a b key new old A_mem B_mem
    local cnt=0
    # init singletons
    while IFS=',' read -r a b _ || [[ -n "$a" ]]; do
        if ! [[ -v CIRCUITS[$a] ]]; then 
            CIRCUITS[$a]=$next_circuit
            ((next_circuit++))
        fi 

        if ! [[ -v CIRCUITS[$b] ]]; then 
            CIRCUITS[$b]=$next_circuit
            ((next_circuit++))
        fi 

    done < "$POINT_PAIRS"

    while IFS=',' read -r a b _ || [[ -n "$a" ]]; do 
        ((cnt == COUNT)) && print_part_1 ${CIRCUITS[@]} 
        
        if [[ $(echo ${CIRCUITS[@]} | tr -t ' ' '\n' | sort -un | wc -l) -le 1 ]]; then 
            printf "$A_mem\n$B_mem\n" | awk 'BEGIN { p = 1 } { p *= $1 } END { print "PART 2: " p}'
            break
        fi 
        
        new=${CIRCUITS[$a]}
        old=${CIRCUITS[$b]}

        if [[ "$old" != "$new" ]]; then 

            for key in "${!CIRCUITS[@]}"; do 
                if [[ $old == "${CIRCUITS[$key]}" ]]; then 
                    CIRCUITS[$key]=$new
                fi
            done 
        
        fi
        ((cnt++))
        A_mem=$a 
        B_mem=$b

    done < "$POINT_PAIRS"

   


}


main() (
    set_input
    pair_points
    make_circuits

)

(return 0 2>/dev/null) || time main "$@"
