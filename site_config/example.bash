# Add the cluster's hosts here so the cluster can be detected when running on these systems.
# Note: these lines are grepped for, not actually used -- just follow suit.
# If you don't know what to put here, go to a shell prompt and type: echo $HOSTNAME
#
CLUSTER_HOSTNAMES[1]="headnode.example.com"
CLUSTER_HOSTNAMES[2]="scheduler.example.com"
CLUSTER="example"


# It concerned me to leave the password in the project, so source it from
# somewhere else.  A good place is your home's directory.  This is often
# root's home, but we can support non-root users too.
#
# The ~/.nm.config.$CLUSTER file should look like this:
# NM_IPMI_USER=root
# NM_IPMI_PASS=secret
#
if [[ -f $NM_SITE_CONFIG_FILE ]]; then
    source ~/.nm.config.$CLUSTER
else
    echo "WARNING:"
    echo "The env variables NM_IPMI_USER and NM_IPMI_PASS are required."
    echo "Normally this is supplied in ~/.nm.config.$CLUSTER"
fi


# Source optional components
#source $NM_HOME/nodeman_sched_pbs.bash                 # Use if you have PBS
source $NM_HOME/nodeman_sched_slurm.bash               # Use if you have Slurm
#source $NM_HOME/nodeman_util_dell.bash           # Dell specific (mostly firmware) util functions
#source $NM_HOME/nodeman_list_4in1.bash   # list functions useful for chassis with 4 nodes in them

# Here you may also want to override where data and logs are written
# Defaults to $NM_HOME/data
