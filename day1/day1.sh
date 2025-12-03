#!/bin/bash 


SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. ${SCRIPTDIR}/../utils/nicetohave.sh

get_0_passes()
{
    local position="$1"
    local amount="$2"
    local a=$((amount / 100))
    amount=$((amount - a * 100))

    ((a < 0)) && a=$((a * -1))

    
    position_new=$((position + amount))
    ((position != 0)) && (( position_new <= 0 || 99 < position_new)) && a=$((a+1))
    echo $a
    
}

part()
{
    local PART="$1"
    local count=0
    local position=50
    local position_old
    local N=$(cat $INPUT | wc -l)
    local processed=0
    while read -r instruction; do

        local amount=$(echo $instruction | grep -oE "[0-9]+") 
        position_old=$position
        case "$instruction" in
            R*)
                position=$((position + amount))
                amount_2=$amount
            ;; 
            L*)
                position=$((position - amount))
                amount_2=$((amount * -1))
            ;;
            *) echo "ERROR: crazy instruction: $instruction" && return 1 ;;
        esac

        ((PART == 2)) && count=$((count + $(get_0_passes $position_old $amount_2)))
    
        position=$(((position + (amount / 100 + 1) * 100) % 100))

        ((PART == 1)) && [[ $position -eq 0 ]] && count=$((count+1))
        ((processed++))
        progress_bar $processed $N

        
    done < "$INPUT"
    echo "PART $PART: $count"
}


main()
{
    [ -z "$INPUT" ] && INPUT=${SCRIPTDIR}/input.txt

    part 1
    part 2

}

(return 0 2>/dev/null) || time main