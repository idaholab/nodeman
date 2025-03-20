# Example Usage

## The idea
It's easy to get a list of NodeMan tools since all the tools start with an `nm.`  All you need to do is type `nm.<tab><tab>` for file completion.  The nm.* tools are bash functions that get sourced into your current environment.

## Help
Currently NodeMan doesn't have great help for each tool.  It's a priority to find an __elegant__ way to write and display online help.  Your best resource for now are examples.

## Various Examples

Run df on all the nodes
```
=> nm.nodes | nm.ssh df
# Same as:
# clush -g compute df
```

Give me the service tag from each compute node
```
=> nm.nodes | nm.chassistag
...
compute349: Chassis Service Tag     = 4HV1ABD
compute333: Chassis Service Tag     = CGV1ABD
compute380: Chassis Service Tag     = 6HV1ABD
compute329: Chassis Service Tag     = BHR5ABD
...

```
Make sure all compute nodes are set to Uefi
```
=> nm.nodes | nm.bios.get.bootmode | grep Boot
...
compute233: BootMode=Uefi
compute265: BootMode=Uefi
```

Look at systems with network sick vs healthy
```
=> echo compute0{10..12} | nm.split | nm.net.healthy
...
=> echo compute0{10..12} | nm.split | nm.net.sick
...
```

Look at the last `n` lines of dmesg for some nodes
```
=> nm.cluset @rack2 | nm.dmesg 
```

Show the fan RPM and load on the machine.  This uses IPMI and host-ssh simutaniously.
```
=> nm.cluset @rack3 | nm.fanload
```

And do the same and find the 8 highest fan speeds and if they have load.
```
=> nm.nodes | nm.fanload | sort -n -k2 | tail -n 8
```

Check the Dell Thermal Profile to make sure they match.
```
=> nm.cluset @rack1 | nm.system.get.thermalprofile
...
compute045: compute045 Maximum Performance
compute028: compute028 Maximum Performance
compute014: compute014 Maximum Performance
...
```

Look at the fastest fans and see if they've been thermal throttling in dmesg.
```
=> nm.nodes | nm.fan | sort -n -k2 | tail -n 12 | nm.thermalthrottles 
```

Turn on identify, check status, and turn it off again.
```
echo compute158 | nm.identify.on 
echo compute158 | nm.identify.status
echo compute158 | nm.identify.off
```

Give an ordered some of inlet temperatures
```
=> nm.nodes | nm.sensors | grep INLET | cut -d" " -f3 | sort | uniq -c
      1 
     60 22.000
    430 23.000
    255 24.000
     64 25.000
     18 26.000
     12 27.000
      3 28.000
```

A setup of a replacement motherboard
```
echo compute158 | nm.bmc.sslpush 
echo compute158 | nm.firmware.update
echo compute158 | nm.biosconfig.update 
```

See if hyperthreading is on or off and any system event logs

```
10:35:01 echo compute384 | nm.bios.get.logicalproc 
10:36:16 echo compute384 | nm.sel
10:36:20 echo compute384 | nm.sel.viewroll 
```

Store the BIOS config in a file
```
echo compute049 | nm.biosconfig.fetch 
```

If you configured a 4-in-1U chassis or similar, return only one node per chassis, allow you to specify the slot.
```
echo compute100 | nm.neighbors.just.chassis 
echo compute100 | nm.neighbors.just.chassis 2
echo compute100 | nm.neighbors.just.chassis 3
echo compute100 | nm.neighbors.just.chassis 4
```

Identify a node
```
=> echo compute167 | nm.identify.status
compute167: 	LED State :    Not-Blinking
```

Offline a node with a reason (pbs or slurm)
```
echo compute323 | nm.offline "reboot to apply NUMA settings"
```

Power on a list of nodes
```
nm.cluset compute[001-002,006,011-018,022-048,058,064-080] | nm.power.on
```

Give me the IP addresses where scratch is mounted
```
nm.cluset @rack1 | nm.ssh "mount | grep scratch | sed 's/.*mountaddr=\(.*\),mou.*/\1/'" 
```

Show nodes with in an unhealthy state and their last error
```
nm.cluset @rack2 | nm.sel.viewroll | grep -v "= Ok"
```

Group into nodes with the nhc directory and ones without the nhc directory
```
nm.cluset compute[003-006,017-160,168-172,174-247,249-336] | nm.ssh "ls -l /etc/nhc' | clubak -c
```

Looks for nodes offlined with a reason containing "BIOS" and updates their BIOS.
```
sinfo -Nel | grep BIOS | grep gener | grep drained |  nm.biosconfig.update 
```

Find all the nodes with sick "ib" interface but working eithernet and bmc, then give me an uptime of all those
```
nm.nodes | nm.net.sick 2>&1 | grep "ib=1 eth=0 bmc=0" | awk '{ print $2 }' | nm.uptime
```

