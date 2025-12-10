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


get_start_pos()
{
    local first_row="$(head -n 1 "$INPUT")"
    for ((i=0; i < ${#first_row}; i++)); do 
        [[ "${first_row:$i:1}" == 'S' ]] && echo $i && return 0 
    done 
    return 1
}

get_splits()
{
    local row="$1"
    local i 
    for ((i=0; i < ${#row}; i++)); do 
        [[ ${row:$i:1} == '^' ]] && echo -n "$i "
    done 
    echo
}

main()
{
    set -e
    
    local n_splits=0 timelines v1 v2 split new_beams 
    declare -A beams
    beams[$(get_start_pos)]=1

    while read line || [ -n "$line" ]; do 

        unset new_beams
        declare -A new_beams

        for split_idx in $(get_splits $line); do
            if [[ ${beams[$split_idx]} != 0 ]]; then 
                timelines="${beams[$split_idx]}"
                ((n_splits++)) || :

                if [[ -n "${new_beams[$((split_idx + 1))]}" ]]; then 
                    right="${new_beams[$((split_idx + 1))]}"
                else 
                    right=0
                fi 

                if [[ -n "${new_beams[$((split_idx - 1))]}" ]]; then 
                    left="${new_beams[$((split_idx - 1))]}"
                else 
                    left=0
                fi 

                new_beams[$((split_idx - 1))]="$((timelines + left))"
                new_beams[$((split_idx + 1))]="$((timelines + right))"
                beams[$split_idx]=0
            fi
        done 

        for beam_idx in ${!new_beams[@]}; do 
            if [[ -n "${beams[$beam_idx]}" ]]; then 
                tl="${beams[$beam_idx]}"
            else 
                tl=0
            fi
            beams[$beam_idx]="$((tl + ${new_beams[$beam_idx]}))"
        done 

    done < <(tail -n +2 "$INPUT" )

    echo "PART 1: $n_splits"
    echo ${beams[@]} | tr -t ' ' '\n' | awk '{s += $1} END { print "PART 2: " s}'
}

(return 0 2>/dev/null) || time main
