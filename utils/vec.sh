#!/bin/bash

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
