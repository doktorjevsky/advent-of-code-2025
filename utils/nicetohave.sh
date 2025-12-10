#!/bin/bash

progress_bar() {
    local done=$1
    local total=$2
    local width=${3:-40}
    trap 'printf "\033[?25h\n"' EXIT

    # Guard against bad inputs
    if [[ -z $done || -z $total || $total -le 0 ]]; then
        return 1
    fi
    if (( done < 0 )); then done=0; fi
    if (( done > total )); then done=$total; fi

    # Colors
    local RED="\033[0;31m"
    local YELLOW="\033[1;33m"
    local CYAN="\033[0;36m"
    local GREEN="\033[0;32m"
    local BOLD_GREEN="\033[1;32m"
    local RESET="\033[0m"

    # Compute percentage and bar sections
    local percent=$(( done * 100 / total ))
    local filled=$(( done * width / total ))
    local empty=$(( width - filled ))

    # Choose color by percent
    local color=$RED
    if   (( percent >= 30 && percent < 60 )); then color=$YELLOW
    elif (( percent >= 60 && percent < 90 )); then color=$CYAN
    elif (( percent >= 90 )); then color=$GREEN
    elif (( percent > 99 )); then color=$BOLD_GREEN
    fi

    # Build bar strings
    local bar filled_str empty_str
    filled_str=$(printf "%${filled}s" | tr ' ' '#')
    empty_str=$(printf "%${empty}s" | tr ' ' ' ')
    bar="[${filled_str}${empty_str}]"

    
    printf "\033[?25l\r${color}%-*s %3d%%%s" "$((width+2))" "$bar" "$percent" >&2
    echo -en $RESET >&2
    
    ((percent == 100)) && printf "\033[?25h\n" >&2
}

prompt()
{
    local p="$*"
    local text
    read -r text

    echo "$p $text"
}

min()
{
    local curr="$1"
    
    for ((i=1; i < $(( 1 + $#)); i++)); do 
        (( ${!i} < $curr)) && curr=${!i} 
    done 

    echo $curr
}

max()
{
    local curr="$1"
    shift 
    for ((i=1; i < $((1 + $#)); i++)); do 
        (( ${!i} > $curr )) && curr=${!i} 
    done 

    echo $curr
}


abs()
{
    if (( $1 < 0 )); then
        echo $((-1 * $1))
    else 
        echo $1 
    fi
}

sum() 
{
    local opts
    opts=$(getopt -o c: --long col: -n 'sum' -- "$@")
    if [ $? != 0 ]; then
        echo "Usage: sum [-c column] [file]" >&2
        return 1
    fi
    eval set -- "$opts"

    local col=1

    while true; do
        case "$1" in
            -c|--col) col="$2"; shift 2 ;;
            --) shift; break ;;
            *) break ;;
        esac
    done

    local file=$1  

    if [[ -n "$file" ]]; then
        awk -v c="$col" '{sum += $c} END {print sum}' "$file"
    else
        awk -v c="$col" '{sum += $c} END {print sum}'
    fi
}


repeat()
{
    local separator='\n'
    local times='inf'
    local opts="$(getopt -o "s:n:" -l "sep:,times:" -n 'repeat' -- "$@")"
    eval set -- "$opts"
    while true; do 
        case "$1" in 
            -s|--sep)
                separator="$2"
                shift 2
            ;;
            -n|--times)
                times="$2"
                shift 2
            ;;
            --) shift ; break ;;
        esac
    done 

    local obj="$1" i
    for ((i=0; i < $times; i++)); do 
        printf "%s${separator}" "$obj"

    done 

}


