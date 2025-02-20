# NodeMan: a Node Management tool for HPC

## Description (brief)

Who will find this useful?  (HPC) System administrators who manage nodes.
Sysadmins that use pdsh, clush, and shell scripts will find it familiar.  Sysadmins that find themselves writing scripts with loops will see it is quite powerful.  Sysadmins that write lengthy "one-liners" that they later don't understand will really appreciate the encapsulation NodeMan provides.

Essentially, it is a set of bash functions that use: GNU Parallel, clustershell for host sets, and stdin/stdout to provide a simple set of commands that can be assembled like building blocks.  Passing node lists between tools via pipes is the foundation of how NodeMan works.

The goal is for sysadmins to see extending NodeMan for node managment tasks as less friction than writing shell scripts.  It's totally customizable to your environment -- the source code is simple.  If others can benefit from a `nm.*` tool you create why not share it!

## Examples (Why do I want to use this?)

Give a list of the cluster's nodes
```
# nm.nodes
node001
...
node384
```

Get a list of nodes in rack1 leveraging clustershell's node sets 
```
# nm.cluset @rack1
node001
...
node064
```

Now let's pipe that list to something interesting, like power status
```
# nm.cluset @rack1 | nm.power.status
node001: Chassis Power is on
node002: Chassis Power is off
...
node064: Chassis Power is on
```

Let's turn on systems that are turned off in rack 1
```
# nm.cluset @rack1 | nm.power.status | grep "is off" | nm.power.on
```

Give me a list of nodes that don't have the current firmware and tell the schuduler to mark them offline
```
# nm.nodes | nm.firmware.needed | nm.offline "Needs firmware update"
```

Give me a list of the 12 nodes with the fasts fans, then check for thermal throttling in dmesg on those nodes
```
# nm.nodes | nm.fan | sort -n -k2 | tail -n 12 | nm.thermalthrottles 
node020: 0 
node042: 3
...
```

Let's take the ones with thermal throttles and mark them offline so we can (re-)apply thermal paste
```
# nm.nodes | nm.fan | sort -n -k2 | tail -n 12 | nm.thermalthrottles | grep -v ": 0" | nm.offline "Needs thermal paste"
```

# Simple

No libraries, no GUI, no database.  Install GNU parallel, clustershell, and ipmitool.  Do a small amount of site configuration and you are on your way!

It's easy to create your own NodeMan tools.  If you can write a bash script to do it, you can adapt it into a nm tool that works well with other nm tools.

# Where to go from here

Get started by following the Install document.

Find ideas of how to use nm.* tools (NodeMan) in the Example docuemnt.

If you'd like some coaching on how to extend NodeMan and better understand how it works check out the Design document.
