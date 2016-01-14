#!/bin/bash
unset PID
GRAPH=false
SLEEP_TIME=1
LOG_FILE="usage.log"
GRAPH_FILE="usage.png"
#command tracking
COMMAND=""
FIRST_TIMEOUT=1800 #how long will be waited for first occurence of command in ps
NEXT_TIMEOUT=600 #how long will be waited for next instance to appear in ps

while getopts 'p:gl:d:sc:F:N:' flag; do
  case "${flag}" in
    p) PID="${OPTARG}" ;;
    g) GRAPH=true ;;
    l) LOG_FILE="${OPTARG}" ;;
    d) GRAPH_FILE="${OPTARG}" ;;
    s) SLEEP_TIME="${OPTARG}" ;;
    c) COMMAND="${OPTARG}" ;;
    F) FIRST_TIMEOUT="${OPTARG}" ;;
    N) NEXT_TIMEOUT="${OPTARG}" ;;
    *) echo "Unexpected option ${flag}"; exit 1;;
  esac
done

function count_words {
    echo $#
}

function printlog {
    printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$1"
}

function printerr {
    >&2 printlog "$1"
}

function throwerr {
    printerr "$1"
    ERROR_CODE=1
    if [ -n "$2" ]; then
        ERROR_CODE=$2
    fi
    exit $ERROR_CODE
}

function is_running_process {
  TEST=$(ps --pid $1 -o "pid=") #writes pid to stdout if it is a running process
  if [ -z "$TEST" ]; then
      return 1
  else
      return 0
  fi
}

function monitor_process {
  if [ -n "$PID" ] && is_running_process $PID; then
      while is_running_process $PID; do
          ps --pid $PID -o pid=,size=,%cpu= | while IFS= read -r line;
                                                do printlog "$line";
                                              done >> $LOG_FILE
          if [[ "$GRAPH" = true ]]; then
              gnuplot -c gnuplot.script $LOG_FILE $GRAPH_FILE
          fi
          sleep $SLEEP_TIME
      done
  elif [ -z "$COMMAND" ]; then #ignore this error if process is tracked by command
      throwerr "ERROR: You have to specify a PID of running process!"
  fi
}

function find_pid {
    if [ -z "$COMMAND" ]; then #what command shoudl be tracked?
        throwerr "ERROR: You have to specify command name if you want to track it."
    fi

    unset PID
    TIMEOUT=$1

    while [ $TIMEOUT -gt  0 ]; do
        PID=$(ps -C $COMMAND -o "pid=" --sort="time")
        if [ -n "$PID" ]; then
            WORD_COUNT=$(count_words $PID)

            if [ "$WORD_COUNT" -gt 1 ]; then #more than one PIDs were found
                printlog "INFO: Found $WORD_COUNT PIDs for $COMMAND: ${PID//[[:space:]]/; }" #trim whitespaces
                PID=$(echo "$PID" | head -n 1) #get "newest" PID
            else
                PID=${PID//[[:blank:]]/} #trim spaces
                printlog "INFO: Found PID ($PID) of $COMMAND."
            fi

            export PID
            return 0;
        fi
        TIMEOUT=$((TIMEOUT-1));
        sleep 1
    done
    printerr "ERROR: Looking for PID of $COMMAND timed out after $1 seconds."
    return 1;
}

if [ -n "$PID" -a -z "$COMMAND" ]; then #PID is set and COMMAND is not
    monitor_process $PID
elif [ -z "$PID" -a -n "$COMMAND" ]; then #COMMAND is set and PID is not
    printlog "INFO: Waiting for $COMMAND to appear first time."
    find_pid $FIRST_TIMEOUT > /dev/null
    if [ "$?" -eq 1 ]; then #find_pid failed
        exit 1
    fi
    while true; do
        find_pid $NEXT_TIMEOUT
        if [ "$?" -eq 0 ]; then
            printlog "INFO: Trying to monitor PID $PID."
            monitor_process $PID
        else
            exit 1
        fi
    done
else
    throwerr "ERROR: Invalid options combination!"
fi
