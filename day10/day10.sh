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

binary()
{
    n=$1
    bits=$2
    bin=$(echo "obase=2; $n" | bc)
    printf "%0${bits}d\n" "$bin"
}


# Function calls can sometimes slow down Bash scripts considerably. That is why 
# I don't call any functions ... 
part_1()
{
    local tmp=$(mktemp -d)
    local procs=$(nproc)
    echo "TMP: $tmp"
    local row=0
    while IFS='-' read -r answer buttons || [ -n "$answer" ]; do 
        
        n_buttons="$(echo "$buttons" | wc -w)"
        n_bits="$(( $(echo -n "$answer" | wc -m) - 2 ))"
        buttons=($buttons)
        answer=${answer//'#'/'1'}
        answer=${answer//'.'/'0'}
        answer=${answer//'['/}
        answer=${answer//']'/}
        empty_board=$(binary 0 $n_bits)
        {
        local FILE="$(echo "$anwer $buttons $(date +%s) $RANDOM" | md5sum | awk '{print $1}')"
        for ((i=0; i < 2**${n_buttons}; i++)); do
         
            declare -A board
            for ((j=0; j < $n_bits; j++)); do
                board[$j]=0
            done
            buttons_to_press=$(binary $i $n_buttons)
        
            for ((j=0; j < ${n_buttons}; j++)); do
                if [[ "${buttons_to_press:$j:1}" == '1' ]]; then 
                    button="${buttons[$j]}"
                    button=${button//'('/}
                    button=${button//')'/}
                    button=(${button//','/' '})

                    for b in ${button[@]}; do   
                        light=$(( (${board[$b]} + 1 ) % 2))
                        board[$b]=$light
                    done 
                fi
            done 
            ok=1
        
            for ((j=0; j < ${n_bits}; j++)); do
                
                if [[ ${board[$j]} != ${answer:$j:1} ]]; then 
                     ok=0
                     break
                fi
            done 
         

            if ((ok)); then 
                buttons_to_press=${buttons_to_press//'0'/}
                echo ${#buttons_to_press}
            fi 
   
        done | sort -n | head -n 1 > ${tmp}/${FILE}
        } &

        (( $(jobs -r | wc -l) >= procs)) && wait -n
        
    done < <(paste -d '-' <(awk '{print $1}' "$INPUT") <(grep -Eo "\(.*\)" "$INPUT"))

    wait 

    cat ${tmp}/* | awk '{s += $1} END { print "PART 1: " s}'

    rm -r $tmp
}

# I am NOT going to implement ILP in bash ... 
part_2()
{
    ! [ -e ${SCRIPTDIR}/venv ] && (cd $SCRIPTDIR; python -m venv venv)
    . ${SCRIPTDIR}/venv/bin/activate >/dev/null
    pip install ortools 1>/dev/null 2>&1 
    ${SCRIPTDIR}/part2.py ${INPUT} | prompt "PART 2: "
}

main() (
    part_1
    part_2
)

(return 0 2>/dev/null) || time main "$@"
