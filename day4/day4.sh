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

gr_get()
{
    local -n grid="$1"
    local row="$2"
    local col="$3"
    echo -n "${grid[$row]:$col:1}"
}

in_bounds()
{
    local row="$1"
    local col="$2"
    local ROWS="$3"
    local COLS="$4"
    (( 0 <= row && row < ROWS )) && (( 0 <= col && col < COLS))
}


get_neighbors()
{
    local grid=$1
    local row="$2"
    local col="$3"
    local i j 

    for ((i=-1; i < 2; i++)); do 
        for ((j=-1; j < 2; j++)); do 
            if (( i != 0 || j != 0 )) && in_bounds $((row + i)) $((col + j)) $ROWS $COLS ; then
                gr_get $grid $((row + i)) $((col + j))
            
            fi
        done 
    done 
}

set_grid() {
    local -n gridname="$1"
    mapfile "$1" < "$INPUT"

    ROWS=${#gridname[@]}
    COLS=$(echo ${gridname[0]} | wc -m)
    ((COLS--))
    ((ROWS--))
}

count_char() {
    local str="$1"
    local char="$2"
    local tmp="${str//"$char"/}"
    echo $(( ${#str} - ${#tmp} ))
}

iterate()
{
    local i
    for ((i=0; i < ROWS; i++)); do 
        (
        local j
        local I=$i
        for ((j=0; j < COLS; j++)); do 
            if [[ $(gr_get GRID $I $j) == '@' ]]; then 
            
                local nbors
                nbors=$(get_neighbors GRID $I $j)
                if (( $(count_char $nbors '@') < 4 )); then 
                    echo $I $j
                fi
            
            fi 
        done 
        ) &
        (( $(jobs -r | wc -l) >= $(nproc) )) && wait -n
    done

    wait

}

part_2()
{
    local c y x old_row
    while true; do
        c=0
        while read -r y x; do 
            old_row=${GRID[$y]}
            GRID[$y]="${old_row:0:$x}.${old_row:$((x+1))}"
            ((c++))
        done < <(iterate)
        ((c == 0)) && break
        echo $c
    done | sum | prompt "PART 2: "
     
}

part_1()
{
    iterate | wc -l | prompt "PART 1: "
}

main() (
    set_grid GRID
    part_1
    part_2
    
)

(return 0 2>/dev/null) || time main "$@"
