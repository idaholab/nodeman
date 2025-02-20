# Copyright 2025, Battelle Energy Alliance, LLC
#
# Author:
# Scott Serr
# scott.serr@inl.gov
#
# Description:
# Functions for working with the PBS scheduler
#



N=$(nm.nodes | head -n 1)
# Cluster basename
export NM_CLUBASE=$(echo $N | sed 's/[0-9]\+$//')
unset N


nm.nodes.in.use () {
    qstat -nt | grep -o '${NM_CLUBASE}[0-9]\+' | sort | uniq
}

nm.nodes.free () {
    # avoiding using diff and temporary files
    ALL=$(nm.nodes)
    INUSE=( $(nm.nodes.in.use) )
    for h in $ALL; do
	if [[ ! "${INUSE[*]}" =~ "${h}" ]]; then
	    echo $h
	fi
    done
}



nm.job.current () {
    single () {
	h=$1
	JOBS=$(pbsnodes $h | grep "jobs" | sed 's/.*jobs = //g' | sed 's|,|\n|g' | sed -n 's| *\(.*\)\..*|\1|p' | sort | uniq)
	for J in $JOBS; do
	    STIME=$(qstat -f $J | grep "stime" | sed 's/.*stime = //g' )
	    ETIME=$(qstat -f $J | grep "etime" | sed 's/.*etime = //g' )
	    echo "job: $J stime: $STIME etime: $ETIME"
	done
    }
    export -f single
    nm._parallel -j2 single
}


nm.job.last () {
    single () {
	h=$1
	LOGS=$(find /var/spool/pbs/server_logs -type f -mtime -2 | sort | tr '\n' ' ')
	O=$(cat $LOGS | grep "$h" | grep "Job" | tail -n 1)
	j=$(echo $O | cut -d";" -f5)
	d=$(echo $O | cut -d";" -f1)
	if [[ "$j" != "" ]]; then
	    i=$(qstat -H $j | tail -n 1)
	fi
	echo "$j $d $i"
    }
    export -f single
    nm._parallel -j2 single
}

# nm.cgroup.errors () {
#     single () {
# 	lookback_sec=$(( $1 * 60 ))
# 	now=$(date '+%F %T')
# 	now_sec=$(date +%s)
# 	after_sec=$(( $now_sec - $lookback_sec ))
# 	h=$2
# 	LINE=$(ssh $h "find /var/spool/pbs/mom_logs -type f -mtime -2 -print0 | xargs -0 cat | grep "CgroupProcessingError" | tail -n 1" 2> /dev/null)
# 	datestamp_sec=$(date +%s -d "$(echo "$LINE" | cut -d: -f1)")
# 	if (( $datestamp_sec > $after_sec )); then
# 	    echo $h $LINE
# 	fi
#     }
#     if [[ "$1" == "" ]]; then
# 	h=10
#     else
# 	h=$1
#     fi
#     export -f single
#     parallel -j0 single $h
# }

nm.cgroup.errors () {
    single () {
	h=$1
	LINE=$(ssh $h "find /var/spool/pbs/mom_logs -type f -mtime -2 -print0 | xargs -0 cat | grep "CgroupProcessingError" | tail -n 1" 2> /dev/null)
	if [[ "$LINE" != "" ]]; then
	    echo $h $LINE
	fi
    }
    export -f single
    nm._parallel -j2 single
}

nm.cgroup.error.15min () {
    single () {
	h=$1
	LINE=$(ssh $h "find /var/spool/pbs/mom_logs -type f -mmin -20 -print0 | xargs -0 cat | grep 'CgroupProcessingError' | tail -n 1" 2> /dev/null)
	if [[ "$LINE" != "" ]]; then
	    err_sec=$(date -d "${LINE%%;*}" '+%s')
	    now_sec=$(date '+%s')
	    diff=$(($now_sec - $err_sec))
	    if [ $diff -le 1000 ]; then 
	        echo $h $LINE
	    fi
	fi
    }
    export -f single
    nm._parallel -j2 single
}



nm.offline () {
#    parallel -j1 --xargs -s 50 pbsnodes -C \"$1\" -o {}
    nm._parallel -j1 pbsnodes -C \"$1\" -o
}

nm.online () {
    single () {
	nm._log "$1 nm.online action"
	pbsnodes -C "" -r $1
    }
    export -f single
    #    nm._log "nm.online start"
    # parallel -j1 --xargs -s 50 'pbsnodes -C \"\" -r {}'  ### had problems stacking args
    nm._parallel -j1 single
    #    nm._log  "nm.online end"
}

nm.nojobs () {
    single () {
#	nm._log "$1 nm.online action"
	OUT=$(pbsnodes $1 | grep jobs)
	if [[ "$OUT" == "" ]]; then
	    echo $1
	fi
    }
    export -f single
#    nm._log "nm.online start"
    # parallel -j1 --xargs -s 50 'pbsnodes -C \"\" -r {}'  ### had problems stacking args
    nm._parallel -j1 single 
#    nm._log  "nm.online end"
}



nm.schgrep () {
    nm.clean | pbsnodes -l | grep "$1" | nm.clean
}



nm.nodes.empty.soon () {
    if [ "$1" == "" ]; then
	look=60
    else
	look=$1
    fi
    
    qstat -r | tail -n +6 | sed 's/\([^.]*\)\..* \(.*\) R \(.*\)/\1 \2 \3/' | while read jobid atime rtime; do
	ahour="${atime%%:*}"
	amin="${atime##*:}"
	rhour="${rtime%%:*}"
	rmin="${rtime##*:}"
	# the 10# is a trick to force bash into treating numbers base10 rather than base8 if they have a leading 0
	atime=$(( 10#$ahour * 60 + 10#$amin ))
	rtime=$(( 10#$rhour * 60 + 10#$rmin ))
	difftime=$(( $atime - $rtime ))
	#echo " $atime $rtime $difftime"
	
	if (( $difftime <= $look )); then
	    #	echo "$jobid $difftime"
	    qstat -nt $jobid | grep -o '${NM_CLUBASE}[0-9]\+' | while read node; do
		echo "$node $difftime $jobid"
	    done
	fi
    done

}
