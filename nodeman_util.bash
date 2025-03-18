# Copyright 2025, Battelle Energy Alliance, LLC
#
# Author:
# Scott Serr
# scott.serr@inl.gov
#
# Description:
# Basic utility functions that should work on all systems

# Common parallel switches see usages in code
# -j --delay --timeout --tagstring --line-buffer

# default output grouping vs --line-buffer
# default grouping will emit output as soon as a job is done
# --line-buffer will emit output all the while the job is working
# #echo -e "foo\nbar" | parallel "for f in 1 2 3; do echo $f {}; sleep 1; done"
# echo -e "foo\nbar" | parallel "for f in 1 2 3; do if [[ "{}" == "foo" ]]; then sleep 1; fi; echo $f {}; sleep 1; done"

nm.net.healthy () {
    single () {
	h=$1
	ping -c 2 $h.ib > /dev/null 2>&1
	ib=$?
	ping -c 2 $h.eth > /dev/null 2>&1
	eth=$?
	ping -c 2 $h.bmc > /dev/null 2>&1
	bmc=$?
	if [[ $ib == 0 && $eth == 0 && $bmc == 0 ]]; then
	    echo "healthy" > /dev/stdout
	else
	    echo "ping failed: ib=$ib eth=$eth bmc=$bmc" > /dev/stderr
	fi
    }
    export -f single
    nm._parallel -j200 --delay .01 single
}

nm.net.sick () {
    single () {
	h=$1
	ping -c 1 $h.ib > /dev/null 2>&1
	ib=$?
	sleep .1
	ping -c 1 $h.eth > /dev/null 2>&1
	sleep .1
	ping -c 1 $h.eth > /dev/null 2>&1
	eth=$?
	sleep .1
	ping -c 1 $h.bmc > /dev/null 2>&1
	bmc=$?
	if [[ $ib == 0 && $eth == 0 && $bmc == 0 ]]; then
	    # do nothing?
	    echo $h > /dev/null
	else
	    echo "sick" > /dev/stdout
	    echo "ping failed: ib=$ib eth=$eth bmc=$bmc" > /dev/stderr
	fi
    }
    export -f single
    nm._parallel -j200 --delay .01 single
}

nm.uptime () {
    single () {
	OUT=$(ssh $1 uptime)
	echo $OUT
    }
    export -f single
    nm._parallel -j0 --delay .02 single
}

nm.ssh () {
    single () {
	ssh $*
    }
    export -f single
    nm._parallel -j200 --timeout 30 --line-buffer single {} $*
}

nm.sel () {
    nm._parallel -j100 --timeout 1m $NM_IPMI -H {}.bmc sel elist
}

nm.bmc.reset () {
    nm._parallel -j100 --timeout 1m $NM_IPMI -H {}.bmc mc reset cold
}

nm.power.status () {
    single () {
	h=$1
	$NM_IPMI -H $h.bmc chassis power status
    }
    export -f single
    nm._parallel -j50 --tagstring "{}: " single
}

nm.reboot () {
    nm._parallel -j0 --delay .2 'sudo ssh {} "reboot" < /dev/null; sleep 5; echo {};'
}

nm.reboot.slow () {
    nm._parallel -j0 --delay 2 'sudo ssh {} "reboot" < /dev/null; sleep 5; echo {};'
}

nm.poweroff () {
    nm._parallel -j0 --delay .1 'sudo ssh {} "poweroff" < /dev/null; sleep 5; echo {};'
}

nm.power.cycle () {
    single () {
	h=$1
	$NM_IPMI -H $h.bmc chassis power cycle > /dev/null
	sleep 2
	$NM_IPMI -H $h.bmc chassis power on > /dev/null 2>&1 
#	sleep 8
#	echo "$h $($NM_IPMI -H $h.bmc chassis power status)"
	echo $h
    }
    export -f single
    nm._parallel -j50 --timeout 1m single
}

nm.power.cycle.slow () {
    single () {
	h=$1
	$NM_IPMI -H $h.bmc chassis power cycle > /dev/null
	sleep 2
	$NM_IPMI -H $h.bmc chassis power on > /dev/null 2>&1 
#	sleep 8
#	echo "$h $($NM_IPMI -H $h.bmc chassis power status)"
	echo $h
    }
    export -f single
    nm._parallel --delay 1 --timeout 1m single
}

nm.power.on.slow () {
    nm._parallel --delay 1.2 --timeout 10s $NM_IPMI -H {}.bmc chassis power on > /dev/null
}

nm.power.on.slow.visual () {
    nm._parallel --delay 3 --timeout 10s $NM_IPMI -H {}.bmc chassis power on > /dev/null
}

nm.power.on () {
    nm._parallel --delay .1 --timeout 10s $NM_IPMI -H {}.bmc chassis power on > /dev/null
}

nm.power.off () {
    nm._parallel -j10 --timeout 10s $NM_IPMI -H {}.bmc chassis power off > /dev/null
}

nm.power.off.slow () {
    nm._parallel --delay .08 --timeout 10s $NM_IPMI -H {}.bmc chassis power off > /dev/null
}

nm.dmesg () {
    single () {
	h=$1
	ssh $h 'dmesg -T | tail -10' < /dev/null
    }
    export -f single
    nm._parallel -j200  --timeout 30 single {} $*
}




nm.reading.power () {
    single () {
	h=$1
	OUT=$($NM_IPMI -H $h.bmc dcmi power reading)
	PWR=$(echo "$OUT" | grep Inst | awk '{ print $4 }')
	echo "$PWR"
    }
    export -f single
    nm._parallel -j200 --timeout 30 single {} $*
}

nm.sensors () {
    single () {
	h=$1
	OUT=$($NM_IPMI -H $h.bmc sensor)
	CPU1_TEMP=$(echo "$OUT" | grep "^Temp" | head -1 | awk '{ print $3 }')
	echo "CPU1_TEMP $CPU1_TEMP"
	CPU2_TEMP=$(echo "$OUT" | grep "^Temp" | tail -1 | awk '{ print $3 }')
	echo "CPU2_TEMP $CPU2_TEMP"
	INLET_TEMP=$(echo "$OUT" | grep "^Inlet Temp" | awk '{ print $4 }')
	echo "INLET_TEMP $INLET_TEMP"
    }
    export -f single
    nm._parallel -j200 --timeout 30 single {} $*
}

nm.sdr.power () {
    single () {
       h=$1
       $NM_IPMI -H $h.bmc sdr type 0x03 | grep "Pwr Consumption" | awk '{ print $10 }'
    }
    export -f single
    nm._parallel -j100 single
}

nm.fanload () {
    single () {
	h=$1
	OUT=$($NM_IPMI -H $h.bmc sdr list | grep "RPM")
	MAX=$(echo "$OUT" | awk 'max<$3 || NR==1{ max=$3 } END{ print max }')
	LOAD=$(ssh $h "cat /proc/loadavg" | cut -d" " -f1)
	echo "$MAX $LOAD"
    }
    export -f single
    nm._parallel -j0 --delay .05 --timeout 20 single
}

nm.fan () {
    single () {
	h=$1
	OUT=$($NM_IPMI -H $h.bmc sdr list | grep "RPM")
	MAX=$(echo "$OUT" | awk 'max<$3 || NR==1{ max=$3 } END{ print max }')
	echo "$MAX"
    }
    export -f single
    nm._parallel -j0 --delay .05 --timeout 20 single
}

nm.identify.on () {
    single () {
	h=$1
	$NM_IPMI -H $h.bmc chassis identify force
    }
    if [[ "$1" != "" ]]; then
	single $1
    else
	export -f single
	nm._parallel --line-buffer -j200 --timeout 30 single {} $*
    fi
}

nm.identify.off () {
    single () {
	h=$1
	$NM_IPMI -H $h.bmc chassis identify 0
    }
    if [[ "$1" != "" ]]; then
	single $1
    else
	export -f single
	nm._parallel --line-buffer -j200 --timeout 30 single {} $*
    fi
}

nm.stat.mem () {
    single () {
	h=$1
	OUT=$(ssh $h "cat /proc/meminfo" 2> /dev/null)
	MT=$(echo "$OUT" | grep "MemTotal" | tr -s " ")
	MF=$(echo "$OUT" | grep "MemFree" | tr -s " ")
	MA=$(echo "$OUT" | grep "MemAvailable" | tr -s " ")
	echo "$MT   $MF   $MA"
    }
    export -f single
    nm._parallel -j200 --timeout 30 single {} $*
}

nm.service.tag () {
    single () {
	h=$1
	$NM_IPMI -H $h.bmc fru | grep "Product Serial" | awk '{ print $4 }'
    }
    export -f single
    nm._parallel -j200 --timeout 30 single {} $*
}

nm.thermalthrottles () {
    single () {
	h=$1
	THERMS=$(ssh $h 'dmesg | grep "CPU0: Package temperature above threshold" | wc -l')
	OUT=$(ssh $h 'dmesg -T | grep "Package temperature above" | tail -1' < /dev/null)
	echo "$THERMS $OUT"
    }
    export -f single
    nm._parallel -j200 --timeout 30 single {} $*
}
