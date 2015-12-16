#!/bin/bash
unset PID
COMMAND=""
GRAPH=false
SLEEP_TIME=1
LOG_FILE="usage.log"
GRAPH_FILE="usage.png"

while getopts 'p:gl:d:sc:' flag; do
  case "${flag}" in
    p) PID="${OPTARG}" ;;
    g) GRAPH=true ;;
    l) LOG_FILE="${OPTARG}" ;;
    d) GRAPH_FILE="${OPTARG}" ;;
    s) SLEEP_TIME="${OPTARG}" ;;
    c) COMMAND="${OPTARG}" ;;
    *) echo "Unexpected option ${flag}"; exit 1;;
  esac
done

function count_words {
  echo $#
}

function is_running_process {
  TEST=$(ps --pid $1 -o "pid=")
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
                                                do printf '[%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$line";
                                              done >> $LOG_FILE
          if [[ "$GRAPH" = true ]]; then
            gnuplot -c gnuplot.script $LOG_FILE $GRAPH_FILE
          fi
          sleep $SLEEP_TIME
      done
  else
      >&2 echo "ERROR: You have to specify a PID of running process!"
      exit 1
  fi
}

function find_pid {
  if [ -z "$COMMAND" ]; then #if COMMAND is null
    >&2 echo "ERROR: You have to specify command name if you want to track it."
    exit 1
  fi

  unset PID
  TIMEOUT=$1

  while [ $TIMEOUT -gt  0 ]; do
    PID=$(ps -C $COMMAND -o "pid=" --sort="time") #TODO split, count and print message
    if [ -n "$PID" ]; then
      WORD_COUNT=$(count_words $PID)

      if [ "$WORD_COUNT" -gt 1 ]; then
        echo "INFO: Found $WORD_COUNT PIDs for $COMMAND: ${PID//[[:space:]]/; }"
        #$(echo $PID | tr ' ' ';')
        PID=$(echo "$PID" | head -n 1)
      else
        echo "INFO: Found PID ($PID) of $COMMAND."
      fi

      export PID="${PID//[[:blank:]]/}"
      return 0;
    fi
    TIMEOUT=$((TIMEOUT-1));
    sleep 1
  done
  >&2 echo "ERROR: Looking for PID of $COMMAND timed out after $1 seconds."
  return 1;
}

if [ -n "$PID" -a -z "$COMMAND" ]; then
  monitor_process $PID
elif [ -n "$COMMAND" ]; then
  echo "INFO: Waiting for $COMMAND to appear first time."
  find_pid 1800 > /dev/null
  if [ "$?" -eq 1 ]; then
    exit 1
  fi
  while true; do
    find_pid 60
    if [ "$?" -eq 0 ]; then
      echo "INFO: Trying to monitor PID $PID."
      monitor_process $PID
    else
      exit 1
    fi
  done
fi
