# cpu-mem-usage-monitor
Very simple bash and gnuplot (>=5.0) script to monitor cpu and memory usage of given process in graph

## How to use
Clone repo, mark monitor.sh as an executable running `chmod +x monitor.sh` and run it by `./monitor.sh PID_I_WANNA_MONITOR`. 

Logged raw values will be placed in usage.log files and graph will be placed in usage.png by default.

##Resources
* https://stackoverflow.com/questions/7998302/graphing-a-processs-memory-usage
* http://brunogirin.blogspot.com.au/2010/09/memory-usage-graphs-with-ps-and-gnuplot.html
