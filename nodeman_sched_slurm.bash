# Copyright 2025, Battelle Energy Alliance, LLC
#
# Author:
# Scott Serr
# scott.serr@inl.gov
#
# Description:
# Functions for working with the Slurm scheduler
#


## Need to implement these comparable to the PBS equivalent
# nm.nodes.in.use () {
# nm.nodes.free () {
# nm.schgrep () {


nm.drain () {
    nm._parallel -j1 scontrol update nodename={} state=drain reason=\"$1\"
}

nm.down () {
    nm._parallel -j1 scontrol update nodename={} state=down reason=\"$1\"
}

nm.offline () {
    nm.down "$1"
}

nm.resume () {
    nm._parallel -j1 scontrol update nodename={} state=resume
}

nm.online () {
    nm.resume
}
