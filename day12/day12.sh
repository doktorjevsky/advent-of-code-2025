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

# anti-climatic ...
part1()
{

    declare -A SHAPES 
    declare -A INSTANCES

    local current_shape_size=0
    local shape_idx=0
    local instance_idx=0 i
    while IFS='\n' read -a line || [ -n "$line" ]; do 
        case "$line" in 
            [0-9]:)
                line=${line//:/}
                shape_idx=$line
            ;;
            '#'*|'.'*)
                line=${line//'.'/}
                current_shape_size=$((current_shape_size + ${#line}))
            ;;
            '')
                SHAPES[$shape_idx]=$current_shape_size
                current_shape_size=0
            ;;
            
            [0-9]*x[0-9]*)
                IFS=': ' read dim n_shapes <<< "$line" 
                IFS=' '
                dim=${dim//'x'/'*'}
                instance_area=$((dim))
                n_shapes=($n_shapes)

                s=0
                for i in ${!n_shapes[@]}; do 
                    s=$(( s + ${SHAPES[$i]} * ${n_shapes[$i]}))
                done 
                echo $((s <= instance_area))

                IFS='\n'
            
            ;;

        esac

    done < "$INPUT" | awk '{ sum += $1} END {print "PART 1: " sum}'

}


main() (
    part1
)

(return 0 2>/dev/null) || time main "$@"
