# Installation

## Dependencies (clustershell, ipmitool, parallel)

### clustershell

This package gives you (and the NodeMan tools) an easy way to generate host lists with cluset.  It also comes with clubak which can aggregate output for you.
```
# requires the EPEL repository
dnf install clustershell
```

### ipmitool

```
dnf install ipmitool
```

### parallel (GNU Parallel)

For now NodeMan uses GNU parallel extensively.  It is released under the GPL, but has a strange citation request.
```
# requires the EPEL repository
dnf install parallel
```

And here is how to agree to the citation request.  Each user of NodeMan will need to do this once.  Please don't get turned off by this process.

```
# to see the citation request
## echo test | parallel echo

parallel --citation
  Type: 'will cite' and press enter.
  > will cite
```

This basically sets up a few configuration files in ~/.parallel/ so you aren't nagged to cite the GNU parallel author's work every time you run parallel.


## NodeMan installation

If you haven't already downloaded NodeMan you can clone it or grab the tar here: https://github.com/idaholab/nodeman

Put the `nodeman` directory wherever you like.  It could be in your home or on a network location.  For this example let's just run it out of our home.

```
cd ~
git clone https://github.com/idaholab/nodeman.git
cd nodeman
ls -l
```

You will notice the `site_config` directory.  We need to create a site configuration file.  Take a look at the example in `example.bash` and copy it.

```
cd site_config
cat example.bash
# cp example.bash <cluster name>.bash
cp example.bash bigcluster.bash
```

The `bigcluster.bash` will need a few modifications.

The top section is a way to give NodeMan a way to map hosts you are running on to a cluster configuration.  Let's make some modifications assuming we have a cluster named bigcluster and a few admin hosts we will run NodeMan on: bigadmin and bigslurm.  (Note: run `hostname` on a host to get it's fully qualified name.)
```
# Add the cluster's hosts here so the cluster can be detected when running on these systems.
# Keep them commented out
# CLUSTER_HOSTNAME=bigadmin.hpc.example.com
# CLUSTER_HOSTNAME=bigslurm.hpc.example.com

CLUSTER="bigcluster"
```

Now toward the bottom of the config file you can turn on or off optional components.  Assuming we are running slurm.  (Note: if you want to use the Dell components you'll need racadm installed.)

```
# Source optional components
#source $NM_HOME/nodeman_sched_pbs.bash                 # Use if you have PBS
source $NM_HOME/nodeman_sched_slurm.bash               # Use if you have Slurm
#source $NM_HOME/nodeman_util_dell.bash           # Dell specific (mostly firmware) util functions
#source $NM_HOME/nodeman_list_4in1.bash   # list functions useful for chassis with 4 nodes in them
```

Now to configure your IPMI username and password.  Currently NodeMan just sources ~/.nm.config.$CLUSTER.  The simplest way to set the username and password is just set the variables there:
```
# Nodeman IPMI config
NM_IPMI_USER='root'
NM_IPMI_PASS='secret'
```

## Running NodeMan

You will need to source `nodeman.bash`
```
source ~/nodeman/nodeman.bash
```

Now all the NodeMan functions are available, give it a try:
```
nm.nodes | nm.uptime
```
