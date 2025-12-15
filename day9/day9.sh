#!/bin/bash
SCRIPTDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

. ${SCRIPTDIR}/../utils/nicetohave.sh

if [ -z "$INPUT" -o "$1" == "test" ]; then 
    if [[ "$1" == "test" ]]; then 
        INPUT="${SCRIPTDIR}/test.txt"
        shift
    else
        INPUT=${SCRIPTDIR}/input.txt
    fi 
fi


clean_data()
{
    sed -i 's|,| |g' "$INPUT"
}

area()
{
    local x=$1
    local y=$2
    local X=$3
    local Y=$4

    echo -n $(( ($(abs $(( x - X))) + 1) * (1 + $(abs $(( y - Y))))))
}

get_rect()
{
    local x1=$1 y1=$2 x2=$3 y2=$4
    local t

    # special case for points on the same axis
    if (( x1 == x2 || y1 == y2 )); then 
        printf "$x1\n$y1\n$x2\n$y2\n$x2\n$y2\n$x1\n$y1\n"
        return 
    fi 

    if (( x1 > x2 )); then 
        t=$x1 
        x1=$x2 
        x2=$t 
    fi 

    if (( y1 > y2 )); then 
        t=$y1 
        y1=$y2 
        y2=$t 

    fi 

    # x1 < x2 && y1 < y2 

    # x1 y1     x2 y1
    #
    # x1 y2     x2 y2 

    printf "$x1\n$y1\n$x2\n$y1\n$x2\n$y2\n$x1\n$y2\n"
}

overlaps()
{
    local -n ps="$1"
    local p1="$2"
    local p2="$3"
    local i j xi yi xj yj xr1 xr2 yr1 yr2 t
    local N=${#ps[@]}
    local is_overlap
    local rectangle
    local dist
    mapfile -t rectangle < <(get_rect $p1 $p2)
    for ((i=0; i < N; i++)); do 
        read xi yi <<< "${ps[$i]}"
        read xj yj <<< "${ps[$(( (i + 1) % N))]}"

        # only one of these conditions will be true 
        if (( xi > xj)); then 
            t=$xi 
            xi=$xj 
            xj=$t
        fi 

        if (( yi > yj)); then 
            t=$yi 
            yi=$yj 
            yj=$t
        fi 

        

        # xi <= xj && yi <= yj is true from here 

        for ((j=0; j < ${#rectangle[@]}; j=j+2)); do 
            xr1=${rectangle[$j]}
            yr1=${rectangle[$(( (j+1) % 8))]}
            xr2=${rectangle[$(( (j+2) % 8))]}
            yr2=${rectangle[$(( (j+3) % 8))]}

            dist=$(( (O_X - xr1)**2 + (O_Y - yr1)**2))

            if (( dist > R_SQ )); then 
                return 0 
            fi 

            dist=$(( (O_X - xr2)**2 +  (O_Y - yr2)**2))

            if (( dist > R_SQ )); then 
                return 0 
            fi 
 
            # the lines of the polygon is either vertical or horizontal 
            if (( yi == yj )); then 
                # --- horizontal line 
                # there is overlap if yr1 and yr2 is on either side of the line 
                # on the line is ok
                # and xr1 and xr2 is within xi and xj 

                # this condition can only be true if yr1 != yr2, which means that xr1 == xr2 follows 
                if (( yr1 < yi && yi < yr2)) || ((yr2 < yi && yi < yr1)); then 
                    (( xi < xr1 && xr1 < xj ))  && return 0
                fi

            else 
                # same logic but for x

                if (( xr1 < xi && xi < xr2 )) || (( xr2 < xi && xi < xr1 )); then 
                    (( yi < yr1 && yr1 < yj )) && return 0
                fi
            fi 

        done 
        
    done 

    return 1

}

part_2()
{
    mapfile -t POINTS < "$INPUT"
    local tmp=$(mktemp -d)
    local procs=$(nproc)
    echo "TMP: $tmp"
    for (( i=0; i < ${#POINTS[@]}-1; i++)); do 
    {
        local Pi Pj
        for (( j=i+1; j < ${#POINTS[@]}; j++)); do 
            # potential red corners 
            Pi=${POINTS[$i]} 
            Pj=${POINTS[$j]}
            
            overlaps POINTS "$Pi" "$Pj" || (area $Pi $Pj && echo; echo $Pi $Pj >> result.log )

        done 
    } > ${tmp}/${i} &
    (( $(jobs -r | wc -l) >= procs)) && wait -n
    done 

    wait 
    cat ${tmp}/* | sort -n | tail -n 1 | prompt "PART 2: "
    rm -r $tmp

}


part_1()
{
    local i j
    mapfile -t POINTS < "$INPUT"
    local tmp=$(mktemp -d)
    echo "TMP: $tmp"
    for ((i=0; i < ${#POINTS[@]} - 1; i++)); do 
    {
        local new_area=0
        local max_area=0
        for ((j=i+1; j < ${#POINTS[@]}; j++)); do
            new_area=$(area ${POINTS[$i]} ${POINTS[$j]})

            (( new_area > max_area)) && max_area=$new_area
            
        done 
        echo $max_area > ${tmp}/${i}
    } & 
        (( $(jobs -r | wc -l ) >= $(nproc))) && wait -n
    done 
    wait
    mapfile -t results < <(cat ${tmp}/*)
    max ${results[@]} | prompt "PART 1: "
    rm -r $tmp
}

set_global_vars()
{
    read MAX_X MIN_X <<< $(awk -v col=1 'BEGIN {max=-1; min=2**64} { if (max < $col) max = $col} { if (min > $col) min = $col } END {print max " " min}' $INPUT)
    read MAX_Y MIN_Y <<< $(awk -v col=2 'BEGIN {max=-1; min=2**64} { if (max < $col) max = $col} { if (min > $col) min = $col } END {print max " " min}' $INPUT)

    echo $MIN_X $MAX_X
    echo $MIN_Y $MAX_Y
}

dist_sq()
{
    local x1=$1 y1=$2 x2=$3 y2=$4
    echo $(( (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2)))
}

main() (

    
    O_Y=50000
    O_X=50000
    R=49500
    R_SQ=$((R * R))

    echo "($O_X, $O_Y) R: $R R^2: $R_SQ"

    clean_data
    part_1
    part_2
)

(return 0 2>/dev/null) || time main "$@"


