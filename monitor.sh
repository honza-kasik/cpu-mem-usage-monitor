#!/bin/bash
GRAPH=false
SLEEP_TIME=1
LOG_FILE="usage.log"
GRAPH_FILE="usage.png"

while getopts 'p:gl:d:s' flag; do
  case "${flag}" in
    p) PID="${OPTARG}" ;;
    g) GRAPH=true ;;
    l) LOG_FILE="${OPTARG}" ;;
    d) GRAPH_FILE="${OPTARG}" ;;
    s) SLEEP_TIME="${OPTARG}" ;;
    *) echo "Unexpected option ${flag}"; exit 42;;
  esac
done

if [ -n "$PID" ] && ps --pid $PID -o "pid=" >/dev/null 2>&1; then
    while ps --pid $PID -o "pid=" >/dev/null 2>&1; do
        ps --pid $PID -o pid=,size=,%cpu= | while IFS= read -r line;
                                              do printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line";
                                            done >> $LOG_FILE
        if [[ "$GRAPH" = true ]]; then
          gnuplot -c gnuplot.script $LOG_FILE $GRAPH_FILE
        fi
        sleep $SLEEP_TIME
    done
else
    >&2 echo "ERROR: You have to supply a PID of running process!";
    exit 42
fi
