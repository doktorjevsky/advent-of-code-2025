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

part_1()
{

    local opts=$(tail -n 1 $INPUT | tr -d ' ')
    local expr="" 
    local i
    local res=0
    local input=$(head -n -1 $INPUT)
    local opt
    for ((i=0; i < ${#opts}; i++)); do 
        opt=${opts:$i:1}
        echo "$input" | 
        awk -v opt="$opt" -v i=$((i+1)) 'BEGIN{ if (opt == "*") result=1} { if (opt == "+") result += $i; else result *= $i; } END {print result}' 
    done | 
    awk '{ sum += $1 } END { print "PART 1: " sum }'
}

part_2()
{
    local n_lines=0
    local count last op 
    local ops=""
    while read line || [[ -n "$line" ]]; do 
        count=$(echo $line | wc -m)
        (( count > n_lines )) && n_lines=$count
    done < $INPUT
    
    for ((i=1; i < $((n_lines + 1)); i++)); do 
        
        res="$(cut -c$i "$INPUT" | tr -d '\n')"
        [[ "${res: -1}" == "*" || "${res: -1}" == "+" ]] && printf "\n"
        printf "$res"  
      
    done | 
    

    while read -r line || [ -n "$line" ]; do
        
        op=$(printf "$line" | grep -Eo "[*+]")
      

        printf "$line"    | 
        grep -Eo "[0-9]+" | 
        awk -v o="$op" 'BEGIN{if (o == "*") res=1} {if (o == "*") res *= $1; else res += $1;} END { print res}'
       
    done | awk '{res += $1} END {print "PART 2: " res}'
    
    
}


main()
{
    part_1
    part_2
}

(return 0 2>/dev/null) || time main 