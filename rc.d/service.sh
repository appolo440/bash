#!/bin/bash

# chkconfig: - 10 05
# description: SSH Server
# processname: sshd

# Объявляем имя сервиса и каталог размещения.
HOMEDIR="/usr/sbin"
SRVNAME="sshd"

# 1. Выбираем их всех процессов необходимый, получаем текущий номер/pid процесса и заносим его в переменную.
# 2. Выбираем полную информацию о запущенном процессе, заносим её в переменную.

SRVPID=`ps aux | grep ${SRVNAME} | grep -v grep | awk {'print $2'}`
SRVSTATUS=`ps aux | grep ${SRVNAME} | grep -v grep`

# ОБРАБОТЧИК СЦЕНАРИЯ START.
start() {

	# Если переменная ${SRVPID} пустая, значит начинаем стартовать сервис.
	# Изначально предпологается что сервис не запущен в системе, по этому переменная должна быть пуста. 
	# Но если сервис был запущен, например вручную, то переменная получит его PID и перейдет к другому условию.
	if [ -z ${SRVPID} ]; then
		
		# Начинаем запуск процесса и проверяем запустился ли он, если сервис присуствует в процессах
		# получаем его PID и заносим в перменную для продолжения условия.
		${HOMEDIR}/${SRVNAME} -D > /dev/null 2>&1 &
		SRVPID=`ps aux | grep ${SRVNAME} | grep -v grep | awk {'print $2'}`

		# Если по какой-то причине сервис не удалось старовать, переменная не будет содержать PID процесса.
		# выводим сообщение что возникла ошибка, если все хорошо говорим об этом и выходим. 
		if [ -z ${SRVPID} ]; then
		echo -e '[ \E[31;40mERROR \E[39;40m] Start serveice error!'; tput sgr0
		else
		echo -e '[ \E[32;40mOK \E[39;40m] Starting serveice done!'; tput sgr0
		fi

	else
	
	# Если пользователь ещё раз запустит обработку старта, но программа уже запущена, выводим об этом сообщение и выходим.
	echo -e '[ \E[36;40mINFO \E[39;40m] Service is alredy running now!'; tput sgr0
	exit 0;

	fi
        }
		
# ОБРАБОТЧИК СЦЕНАРИЯ STOP.
stop() {
	
	# Если PID процесса пустой, значит он не запущен в системе, говорим об этом и выходим.
	if [ -z ${SRVPID} ]
	then
		echo -e '[ \E[36;40mINFO \E[39;40m] Service not running!'; tput sgr0
		exit 0
	else
		
		# В противном случае, завершаем процесс, проверяем завершился ли процесс получая его PID,
		# если при получении переменная остается пустой, значит процесс завершился, выводим сообщение
		# о том что процесс завершился, в противном случае, гововрим что процесс все ещё существует!
		kill -9 ${SRVPID}
		SRVPID=`ps aux | grep ${SRVNAME} | grep -v grep | awk {'print $2'}`
		if [ -z ${SRVPID} ]; then
		echo -e '[ \E[32;40mOK \E[39;40m] Serveice stop!'; tput sgr0
		else
		echo -e '[ \E[31;40mERROR \E[39;40m] Service still runing!'; tput sgr0
		fi
	fi
       }

# ОБРАБОТЧИК СЦЕНАРИЯ RESTART.
restart() {
	
	# Проверяем запущен ли в данный момент сервис, если сервис не запущен, пробуем его запустить.
	# Если сервис запустился удачно, говорим об этом или сообщаем об ошибке запуска.
	if [ -z ${SRVPID} ]
	then
		${HOMEDIR}/${SRVNAME} -D > /dev/null 2>&1 &
		SRVPID=`ps aux | grep ${SRVNAME} | grep -v grep | awk {'print $2'}`

		if [ -z ${SRVPID} ]; then
		echo -e '[ \E[31;40mERROR \E[39;40m] Restarting serveice error!'; tput sgr0
		else
		echo -e '[ \E[32;40mOK \E[39;40m] Restarting serveice done!'; tput sgr0
		fi

	else
		# Если сервис уже был запущен, завершаем его процесс и пытаемся его запустить.
		# Если сервис запустился удачно, говорим об этом или сообщаем об ошибке запуска.
		kill -9 ${SRVPID}
		${HOMEDIR}/${SRVNAME} -D > /dev/null 2>&1 &

		SRVPID=`ps aux | grep ${SRVNAME} | grep -v grep | awk {'print $2'}`
		if [ -z ${SRVPID} ]; then
		echo -e '[ \E[31;40mERROR \E[39;40m] Restarting serveice error!'; tput sgr0
		else
		echo -e '[ \E[32;40mOK \E[39;40m] Restarting serveice done!'; tput sgr0
		fil
	fi
       }

# ОБРАБОТЧИК СЦЕНАРИЯ STATUS.
status() {

	# Если сервис не запущен, выводим сообщение об этом, в противном случае,
	# говорим что все хорошо и выводим информацию о сервисе.
	if [ -z ${SRVPID} ]
	then
		echo -e '[ \E[36;40mINFO \E[39;40m] Service not running!'; tput sgr0
		exit 0
	else
		echo -e '[ \E[36;40mINFO \E[39;40m] Service is running now!'; tput sgr0
		echo -e '[ \E[36;40mINFO \E[39;40m] Info:' ${SRVSTATUS}; tput sgr0
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
