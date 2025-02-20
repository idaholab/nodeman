# Copyright 2025, Battelle Energy Alliance, LLC
#
# Author:
# Scott Serr
# scott.serr@inl.gov
#
# Description:
# List functions for 4 nodes in 1 chassis

N=$(nm.nodes | head -n 1)
# Cluster basename
export NM_CLUBASE=$(echo $N | sed 's/[0-9]\+$//')
# Cluster number of digits
export NM_CLUDIGITS=$(( ${#N} - ${#NM_CLUBASE} ))
unset N

nm.neighbors.and.me () {
    while read h; do
	n=${h//$NM_CLUBASE/}
	n=$(expr $n + 0 ) # We want decimal math, hex or oct, remove zeros
	basen=$((($n-1) / 4 * 4))
	
	for i in {1..4}; do
	    v=$(($basen + i))
	    v=$NM_CLUBASE$(printf "%0${NM_CLUDIGITS}d\n" $v)
	    echo $v
	done
    done | sort | uniq
}

nm.neighbors () {
    while read h; do
	echo $h | nm.neighbors.and.me | grep -v "$h"
    done
}

nm.neighbors.just.chassis () {
    if [[ "$1" == "" ]]; then
	OFFS=1
    else
	OFFS=$1
    fi
    while read h; do
	n=${h//$NM_CLUBASE/}
	n=$(expr $n + 0 ) # We want decimal math
	basen=$((($n-1) / 4 * 4))
	v=$(($basen + $OFFS))
	v=$NM_CLUBASE$(printf "%0${NM_CLUDIGITS}d\n" $v)
	echo $v
    done | sort | uniq
}
