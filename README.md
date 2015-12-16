# cpu-mem-usage-monitor
Very simple bash and gnuplot (>=5.0) script to monitor cpu and memory usage of given process in graph

## How to use
Clone repo, mark monitor.sh as an executable running `chmod +x monitor.sh` and run it by
```bash
./monitor.sh [OPTIONS]... -p PID | [OPTIONS]... -c COMMAND
```

### Options
* `-p PID` PID which will be monitored
* `[-g]` The graph will be created
* `[-l FILE]` Log file path
* `[-d FILE]` Graph file path
* `[-s NUMBER]` Time after the values will be added to log
* `-c COMMAND` Command name will be tracked in system instead of PID

### Example
`./monitor.sh -c firefox` will track different instances of Firefox browser in system one at a time (always the newest instance if previously watched was killed).

### Notes
Logged raw values will be placed in usage.log files and graph will be placed in usage.png by default. Graph **will not be created** by default.

## Resources
* https://stackoverflow.com/questions/7998302/graphing-a-processs-memory-usage
* http://brunogirin.blogspot.com.au/2010/09/memory-usage-graphs-with-ps-and-gnuplot.html
