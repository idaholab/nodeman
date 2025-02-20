# Copyright 2025, Battelle Energy Alliance, LLC
#
# Author:
# Scott Serr
# scott.serr@inl.gov
#
# Description:
# Internal helper functions that other functions may use

nm._date () {
    date "+%Y-%m-%d_%H:%M:%S"
}
export -f nm._date

nm._log () {
    echo "$(nm._date) $1" >> $NM_LOG
}
export -f nm._log

nm._notab() {
    sed 's/\t//g'
}
#export -f nm._notab

nm._parallel () {
    nm.clean | parallel --tagstring "{}: " "$@" | nm._notab
}
#export -f nm._parallel
