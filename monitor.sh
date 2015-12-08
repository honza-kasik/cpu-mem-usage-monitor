while true; do
ps --pid $1 -o pid=,size=,%cpu= >> usage.log
gnuplot gnuplot.script
sleep 1
done &
