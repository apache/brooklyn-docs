---
layout: website-normal
title: Detailed Support Report
toc: /guide/toc.json
---
# {{ page.title }}

If you wish to send a detailed report, then depending on the nature of the problem, consider 
collecting the following information.

See [Brooklyn Slow or Unresponse](slow-unresponsive.html) docs for details of these commands.
 
```bash
BROOKLYN_HOME=/home/users/brooklyn/apache-brooklyn-0.9.0-bin
BROOKLYN_PID=$(cat $BROOKLYN_HOME/pid_java)
REPORT_DIR=/tmp/brooklyn-report/
DEBUG_LOG=${BROOKLYN_HOME}/brooklyn.debug.log

uname -a > ${REPORT_DIR}/uname.txt
df -h > ${REPORT_DIR}/df.txt
cat /proc/cpuinfo > ${REPORT_DIR}/cpuinfo.txt
cat /proc/meminfo > ${REPORT_DIR}/meminfo.txt
ulimit -a > ${REPORT_DIR}/ulimit.txt
cat /proc/${BROOKLYN_PID}/limits >> ${REPORT_DIR}/ulimit.txt
top -n 1 -b > ${REPORT_DIR}/top.txt
lsof -p ${BROOKLYN_PID} > ${REPORT_DIR}/lsof.txt
netstat -an > ${REPORT_DIR}/netstat.txt

jmap -histo:live ${BROOKLYN_PID} > ${REPORT_DIR}/jmap-histo.txt
jmap -heap ${BROOKLYN_PID} > ${REPORT_DIR}/jmap-heap.txt
for i in {1..10}; do
  jstack ${BROOKLYN_PID} > ${REPORT_DIR}/jstack.${i}.txt
  sleep 1
done
grep "brooklyn gc" ${DEBUG_LOG} > ${REPORT_DIR}/brooklyn-gc.txt
grep "events for subscriber" ${DEBUG_LOG} > ${REPORT_DIR}/events-for-subscriber.txt
tar czf brooklyn-report.tgz ${REPORT_DIR}
```

Also consider providing your log files and persisted state, though extreme care should be taken if
these might contain cloud or machine credentials (especially if 
[Externalised Configuration]({{ book.path.guide }}/ops/externalized-configuration.html) 
is not being used for credential storage).

