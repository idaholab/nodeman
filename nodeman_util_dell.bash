# Copyright 2025, Battelle Energy Alliance, LLC
#
# Author:
# Scott Serr
# scott.serr@inl.gov
#
# Description:
# Dell specific functions involving RACADM
#

# We can't hide the password well for racadm
export NM_RACADM="/opt/dell/srvadmin/sbin/racadm -u $NM_IPMI_USER -p $NM_IPMI_PASS"

export NM_BIOS_SETTINGS_FILE=$NM_DATA/golden.json
export NM_CM_FIRM_DIR=$NM_DATA/cm
export NM_FIRMWARE_INSTALLER="/shared/firmware/C6620/install-firmware.sh reboot"

nm.system.set.thermalprofile () {
    single () {
	h=$1.drac.cluster
	TP="$2"
	$NM_RACADM -r $h set System.ThermalSettings.ThermalProfile "$TP"
   }
    export -f single
    if [[ "$1" == "min" ]]; then
	TP="Minimum Power"
    elif [[ "$1" == "max" ]]; then
	TP="Maximum Performance"
    else	 
	TP="Default Thermal Profile Settings"
    fi
    nm._parallel single {} \"$TP\"
}

nm.system.get.thermalprofile () {
    single () {
	h=$1.drac.cluster
	OUT=$($NM_RACADM -r $h get System.ThermalSettings.ThermalProfile | grep ^ThermalProfile | cut -d= -f2)
	echo "$1 $OUT"
    }
    export -f single
    nm._parallel single
}

nm.biosconfig.update () {
    single () {
	h=$1.drac.cluster
	echo $h
	$NM_RACADM -r $h set iDRAC.Lockdown.SystemLockdown 0
	sleep 2
	$NM_RACADM -r $h set -t json -f $NM_BIOS_SETTINGS_FILE
#	sleep 2
#	$NM_RACADM -r $h jobqueue create BIOS.Setup.1-1 -r forced
    }
    export -f single
    nm._parallel single
}

nm.biosconfig.fetch () {
    single () {
	h=$1.drac.cluster
	outf=$NM_NODES_DIR/$1-biosconfig.json
	outfc=$NM_NODES_DIR/$1-biosconfig-component.json
	outff=$NM_NODES_DIR/$1-allsettings.json
	# others we might want NIC.Embedded.1-1-1 iDRAC.Embedded.1
	outc=$($NM_RACADM -r $h get -t json -c BIOS.Setup.1-1 -f $outf | grep "configuration")
	jq '.SystemConfiguration.Components' $outf > $outfc
	sleep 5
	$NM_RACADM -r $h get -t json -f $outff > /dev/null
	echo $1 $outf $outc
    }
    export -f single
    nm._parallel single
}

nm.bios.get.bootmode () {
    single () {
	h=$1.drac.cluster
	$NM_RACADM -r $h get bios.biosbootsettings.BootMode | grep -v "Key"
    }
    export -f single
    nm._parallel single
}

nm.bios.get.logicalproc () {
    single () {
	h=$1.drac.cluster
	$NM_RACADM -r $h get BIOS.ProcSettings.LogicalProc | grep "Log"
    }
    export -f single
    nm._parallel single
}

nm.bios.set.logicalproc.on () {
    single () {
	h=$1.drac.cluster
	$NM_RACADM -r $h set iDRAC.Lockdown.SystemLockdown 0
	sleep 2
	$NM_RACADM -r $h set BIOS.ProcSettings.LogicalProc Enabled
	sleep 2
	$NM_RACADM -r $h jobqueue create BIOS.Setup.1-1 -r forced
    }
    export -f single
    nm._parallel single
}

nm.chassistag () {
    single () {
	h=$1.drac.cluster
	$NM_RACADM -r $h getsysinfo | grep "Chassis Service Tag"
    }
    export -f single
    nm._parallel single
}

nm.firmware._check () {
    DES_BMC="7.10.50.10"
    DES_BIOS="2.2.8"
    h=$1

    OUT=$($NM_RACADM -r $h.drac.cluster getsysinfo)
    BMC=$(echo "$OUT" | grep "Firmware Version" | sed -n 's/.* = \(.*\)/\1/p')
    BIOS=$(echo "$OUT" | grep "System BIOS Version" | sed -n 's/.* = \(.*\)/\1/p')

    echo "$h -- BMC $BMC (Desired $DES_BMC) BIOS $BIOS (Desired $DES_BIOS)" > /dev/stderr

    if [[ "$BIOS" != "" && "$BMC" != "" ]]; then
	#echo "$DES_BMC $BMC $DES_BIOS $BIOS"
	if [[ "$DES_BMC" == "$BMC" && "$DES_BIOS" == "$BIOS" ]]; then
	    exit 0
	else
	    exit 1
	fi
    fi
    exit 2
}
# for gnu parallel to call the fuction
export -f nm.firmware._check


nm.firmware.needed () {
    single () {
	h=$1
	$(nm.firmware._check $h)
	ret=$?
	if [ $ret -eq 1 ]; then
	    echo "needed"
	fi
    }
    export -f single
    nm._parallel -j100 single
}

nm.firmware.good () {
    single () {
	h=$1
	$(nm.firmware._check $h)
	ret=$?
	if [ $ret -eq 0 ]; then
	    echo "good"
	fi
    }
    export -f single
    nm._parallel -j0 single
}

nm.chassis.firmware.version () {
    single () {
	h=$1
	OUT=$($NM_RACADM -r $h.drac.cluster getsysinfo)
	CHASSIS=$(echo "$OUT" | grep "Chassis Manager Version" | sed -n 's/.* = \(.*\)/\1/p')
	echo "$CHASSIS"
    }
    export -f single
    nm._parallel -j0 single
}
export -f nm.chassis.firmware.version  # so the update can reuse this

nm.firmware.all.versions () {
    single () {
	h=$1
	(
	    $NM_RACADM -r $h.drac.cluster getsysinfo
	    $NM_RACADM -r $h.drac.cluster get bios.sysinformation | grep -v "SystemServiceTag"
	    $NM_RACADM -r $h.drac.cluster getversion 
	) | grep -i Version | tr -d '\r' | tr -d ' ' | grep '\S'
    }
    export -f single
    nm._parallel -j0 single
}

nm.firmware.update () {
    single() {
	nm._log "$1 nm.firmware.update start"
	sudo ssh $1 "$NM_FIRMWARE_INSTALLER" < /dev/null &> /tmp/nm.firmware.update.$1.log
	nm._log "$1 firmware.update complete"
	echo "update complete"
    }
    export -f single
    
    if [[ "$1" != "" ]]; then
	echo $1 | nm.firmware.update
    else
	nm._parallel -j0 --delay .1 --timeout 20m --line-buffer single
    fi
}

nm.bmc.sslpush () {
    single() {
	h=$1.drac.cluster
	IP=$(getent hosts $h | awk '{ print $1 }')
	echo $IP
	CMD="$NM_RACADM -r $IP"
	# does this first command do anything? -SMS
	$CMD set idrac.webserver.HostHeaderCheck 0
	$CMD sslkeyupload -t 1 -f $NM_DATA/ssl-self-signed/drac.cluster.key 
	$CMD sslcertupload -t 1 -f $NM_DATA/ssl-self-signed/drac.cluster.crt 
	$CMD racreset
    }
    export -f single
    nm._parallel -j0 single
}

nm.identify.status () {
    single () {
	h=$1
	$NM_RACADM -r $h.drac.cluster getled | grep "LED"
    }
    export -f single
    
    if [[ "$1" != "" ]]; then
	single $1
    else
	nm._parallel -j0 single
    fi
}


nm.sel.viewroll () {
    single () {
	h=$1
	R=$($NM_RACADM -r $h.drac.cluster getsysinfo | grep "Roll")
	E=$($NM_IPMI -H $h.bmc sel elist | grep "Assert" | tail -n1)
	if [[ "$R" == *"RollupStatus"* ]]; then
	    echo "$R $E"
	else
	    echo "Failed"
	fi
    }
    export -f single
    nm._parallel single
}


# nm.firmware.cpld.update () {
#     single() {
# 	sudo ssh $1 "$NM_FIRMWARE_DIR/compute/other/CPLD/CPLD_Firmware_XR7JW_LN_1.1.0_A00.BIN -q" < /dev/null &>> /tmp/nm.firmware.update.$1.log
#     }
#     export -f single
#     nm._parallel -j0 --delay .1 --timeout 20m --line-buffer single
# }


# nm.chassis.firmware.update_2.70_3.51 () {
#     single () {
# 	# check if host is less than 2.70, then install 2.70
# 	h=$1
# 	V=$(echo $h | nm.chassis.firmware.version | cut -f2 -d" ")
#	echo $V
#	if (( $(echo "$V < 2.70" | bc -l) )); then
#	    echo "Upgrading $V to 2.70 ????"
# 	    $NM_RACADM -r $h.drac.cluster update -f $NM_CM_FIRM_DIR/cm_2.70/cm.sc
# 	fi
# 	# check if host is 2.70 or greater but less than 3.51, then install 3.51
# 	if (( $(echo "$V >= 2.70 && $V < 3.51" | bc -l) )); then
# 	    echo "Upgrading $V to 3.51 ????"
# 	    $NM_RACADM -r $h.drac.cluster update -f $NM_CM_FIRM_DIR/cm_3.51/cm.sc
# 	fi
#     }
#     export -f single
#     nm._parallel single
# }

#nm.chassis.firmware.update () {
#    single () {
#	h=$1
#	$NM_RACADM -r $h.drac.cluster update -f $NM_FIRMWARE_DIR/other/Chassis_Management/cm.sc
#    }
#    export -f single
#    nm._parallel -j0 --delay .1 --timeout 10m single
#}
