#!/bin/bash

PID=$1
LOG_FILE="usage.log"

if [ -n "$PID" ] && ps -p "$PID" -o "pid=" >/dev/null 2>&1; then
    while true; do
        ps --pid $1 -o pid=,size=,%cpu= >> $LOG_FILE
        gnuplot -c gnuplot.script $LOG_FILE
        sleep 1
    done
else
    >&2 echo "You have to supply a PID of running process as first argument!";
fi
