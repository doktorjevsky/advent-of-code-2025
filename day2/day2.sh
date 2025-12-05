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


next_illegal()
{
    local num="$1" N A B B_NUM PART

    N=${#num}
    if ((N % 2 == 1)); then 
        PART="1$(yes 0 | head -n $((N/2)) | tr -d '\n')"
        echo "${PART}${PART}"
        return 
    fi
    
    A=${num:0:$((N/2))}
    B=${num:$((N/2)):$N}
    B_NUM=$((10#$B))
    if (( A <= B_NUM )); then 
        ((A++))
        echo "${A}${A}"
    elif (( A > B_NUM )); then 
        echo "${A}${A}"
    else
        echo "${B}${B}"
    fi
}



get_illegals_between_1()
{   
    local A="$1" B="$2" current
    
    ((A--))
    ((B++))
    current="$A"
    while ((current < B)); do 
        current=$(next_illegal $current)
        ((current < B)) && echo $current
    done 
}


is_illegal_2()
{
    local num="$1" N i sub dummy STOP
    N=${#num} 
    STOP=$((N / 2 + 1))
    for ((i=1; i < $STOP; i++)); do
        if ((N % i == 0)); then 
            sub=""
            for ((dummy=1; dummy < $((N / i + 1)); dummy++)); do 
                sub="${sub}${num:0:i}"
            done 

            if [[ "$sub" == $num ]]; then 
                printf "$num\n"
            fi
        fi 
    done 

}

get_illegals_between_2()
{
    local A="$1" B i
    B="$2"
    for ((i=$A; i < $((B + 1)); i++)); do 
        is_illegal_2 $i
    done | sort -n | uniq
}


part()
{
    set -e
    local partnum="$1"
    export -f is_illegal_2 get_illegals_between_1 next_illegal get_illegals_between_2
    tr -t ',' '\n' < "$INPUT"                                         | 
    awk -F '-' '{print $1 " " $2}'                                    | 
    xargs -n2 -P$(nproc) bash -c "get_illegals_between_${partnum} "\$@"" _  | 
    sum | prompt "PART $partnum: "
}

main() (
    part 1 &
    part 2
    wait
)

(return 0 2>/dev/null) || time main "$@"
