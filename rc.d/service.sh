#!/bin/bash
# chkconfig: - 10 05
# description: SSH Server
# processname: sshd

SRVNAME="sshd"
SRVDIR="/usr/sbin"

SRVPID=`ps aux | grep ${SRVNAME} | grep -v grep | awk {'print $2'}`
SRVSTATUS=`ps aux | grep ${SRVNAME} | grep -v grep`

start() {
	echo "Strating service done."
	cd ${HOMEDIR}
	nohup ${SRVDIR}/${SRVNAME} > /dev/null 2>&1 &
	}

stop() {
if [ -z ${SRVPID} ]
	then
		echo "Service is not run."
		exit 0
	else
		echo "Stoping service done."
		kill -9 ${SRVPID}
	fi
	}

restart() {
	if [ -z ${SRVPID} ]
	then
		echo "Service is not run. Run it now!"
	nohup ${SRVDIR}/${SRVNAME} > /dev/null 2>&1 &

	else
	echo "Restarting serveice done!"
	kill -9 ${SRVPID}
	nohup ${SRVDIR}/${SRVNAME} > /dev/null 2>&1 &

	fi
	}

status() {
	if [ -z ${SRVPID} ]
	then
		echo "Service is not run."
		exit 0
	else
		echo "Service running now."
		echo ${SRVSTATUS}
	fi

	}

case "$1" in
	start)

	start
	;;

	stop)

	stop
	;;

	restart)

	restart
	;;

	status)

	status
	;;

	*)

	echo $"Usage: $0 {start|stop|restart|status}"
        exit 1
	esac
exit $?
