# Copyright 2025, Battelle Energy Alliance, LLC
#
# Author:
# Scott Serr
# scott.serr@inl.gov
#
# Description:
# Functions having to do with processing host lists

nm.clean () {
    awk '{ print $1 }' | sed 's/://'
}

nm.split () {
    while read line; do
	for h in $line; do
	    echo $h
	done
    done
}

nm.cluset () {
    cluset -e -S "\n" $*
}

nm.nodes () {
    nm.cluset @compute
}

nm.waitsec () {
    single () {
#	sleep $1
	echo $1
    }
    export -f single
    nm._parallel -j0 --line-buffer --delay $1 single
}

nm.wait () {
    single () {
	sleep 2  # let system settle if we just shut it down
	nm._log "$1 nm.wait start"
	while ! (ssh $1 uptime < /dev/null &> /dev/null); do
	    nm._log "$1 nm.wait loop"
	    sleep 10
	done
	nm._log "$1 nm.wait complete"
	echo $1
    }
    export -f single
    nm._parallel -j0 --timeout 15m single
}

nm.slow () {
    if [[ "$1" == "" ]]; then
	D=1
    else
	D=$1
    fi
    nm._parallel -j10 --delay $D --line-buffer echo
}

nm.list.remove () {
    RLIST="$*"
    while read LINE; do
	if ! grep -q "$LINE" <<< "$RLIST"; then
	    echo $LINE
	fi
    done
}
