# Example Usage

## The idea
It's easy to get a list of NodeMan tools since all the tools start with an `nm.`  All you need to do is type `nm.<tab><tab>` for file completion.  The nm.* tools are bash functions that get sourced into your current environment.

## Help
Currently NodeMan doesn't have great help for each tool.  It's a priority to find an __elegant__ way to write and display online help.  Your best resource for now are examples.

## Basic Examples

Run df on all the nodes
```
nm.nodes | nm.ssh df
# Same as:
# clush -g compute df
```

Give me the service tag from each compute node
```
nm.nodes | nm.chassistag
...
compute348: Chassis Service Tag     = 6RS1ABC
compute349: Chassis Service Tag     = 4HV1ABC
compute333: Chassis Service Tag     = CGV1ABC
compute380: Chassis Service Tag     = 6HV1ABC
compute329: Chassis Service Tag     = BHR5ABC
...

Make sure all compute nodes are set to Uefi
```
nm.nodes | nm.bios.get.bootmode | grep Boot
...
compute233: BootMode=Uefi
compute265: BootMode=Uefi
```

Look at systems with network sick vs healthy
```
echo compute0{10..12} | nm.split | nm.net.healthy
...
echo compute0{10..12} | nm.split | nm.net.sick
...
```

Look at the last `n` lines of dmesg for some nodes
```
nm.cluset @rack2 | nm.dmesg 
```

Show the fan RPM and load on the machine.  This uses IPMI and host-ssh simutaniously.
```
nm.cluset @rack3 | nm.fanload
```

And do the same and find the 8 highest fan speeds and if they have load.
```
nm.nodes | nm.fanload | sort -n -k2 | tail -n 8
```

Check the Dell Thermal Profile to make sure they match.
```
nm.cluset @rack1 | nm.system.get.thermalprofile
...
br045: br045 Maximum Performance
br028: br028 Maximum Performance
br014: br014 Maximum Performance
...

Look at the fastest fans and see if they've been thermal throttling in dmesg.
```
nm.nodes | nm.fan | sort -n -k2 | tail -n 12 | nm.thermalthrottles 
```

Turn on identify, check status, and turn it off again.
```
echo br158 | nm.identify.on 
echo br158 | nm.identify.status
echo br158 | nm.identify.off
```

nm.nodes | nm.sensors | grep INLET | cut -d" " -f3 | sort | uniq -c

echo br158 | nm.identify.on
echo br158 | nm.power.off
echo br158 | nm.bmc.sslpush 
echo br158 | nm.biosconfig.update 
echo br158 | nm.power.cycle 
echo br158 | nm.online 

nm.nodes | nm.uptime | grep "up 6 " | wc -l


10:35:01 echo br384 | nm.bios.get.logicalproc 
10:36:16 echo br384 | nm.sel
10:36:20 echo br384 | nm.sel.viewroll 

nm.nodes | nm.bmc.sslpush 

15:13:59 echo brlogin{1..2} | nm.split | nm.net.healthy 

cat badhot.txt | nm.net.sick 
echo br015 | nm.service.tag 

echo br010 brgateway1 | nm.split | nm.firmware.all.versions 
echo br049 | nm.biosconfig.fetch 

echo br100 | nm.neighbors.just.chassis 
echo br100 | nm.neighbors.just.chassis 2
echo br100 | nm.neighbors.just.chassis 3
echo br100 | nm.neighbors.just.chassis 4

$ echo br167 | nm.identify.status
br167: 	LED State :    Not-Blinking


echo br{201..240} | nm.split | nm.reboot 

echo br323 | nm.offline "reboot to apply NUMA settings"

nm.cluset br[001-002,006,011-018,022-048,058,064-080] | nm.power.on

nm.cluset br[033,081-082,089-090,103,107,112,115,120,133,137-138,153,157,177,307-308] | nm.uptime

nm.cluset @rack1 | nm.ssh "mount | grep scratch | sed 's/.*mountaddr=\(.*\),mou.*/\1/'" 


echo br167 br344 | nm.split | nm.sel.viewroll | grep -v "= Ok"

nm.cluset br[003-006,017-160,168-172,174-247,249-336] | nm.ssh "ls -l /etc/nhc' | clubak -c

sinfo -Nel | grep BI | grep gener | grep drained | nm.clean | nm.biosconfig.update 

sinfo -Nel | grep fresh | nm.clean | sort | uniq > reboot-list

nm.nodes | nm.net.sick 2>&1 | grep "ib=1 eth=0 bmc=0" | awk '{ print $2 }' | nm.uptime

while true; do date; nm.nodes | nm.neighbors.just.chassis | nm.fan | sort -n -k2 | tail -2; sleep 45; done




## Complex Examples


