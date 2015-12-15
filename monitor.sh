#!/bin/bash

PID=$1
SLEEP_TIME=${2-1}
LOG_FILE="usage.log"
GRAPH_FILE="usage.png"

if [ -n "$PID" ] && ps --pid "$PID" -o "pid=" >/dev/null 2>&1; then
    while ps --pid $PID -o "pid=" >/dev/null 2>&1; do
        ps --pid $PID -o pid=,size=,%cpu= | while IFS= read -r line;
                                              do printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line";
                                            done >> $LOG_FILE
        gnuplot -c gnuplot.script $LOG_FILE $GRAPH_FILE
        sleep $SLEEP_TIME
    done
else
    >&2 echo "ERROR: You have to supply a PID of running process as first argument!";
fi
