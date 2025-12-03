#!/bin/bash


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

max()
{
    local m="$1"
    shift 
    local arg
    for arg in $*; do 
        ((arg > m)) && m=$arg 
    done 

    printf '%s' $m
}

