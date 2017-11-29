# Понимание rc.d/init.d скриптов.

Решил немного задокументировать понимание принципов работы rc.d/init.d скриптов на BASH. В данном описании я не затрону тему уровня запуска
приложений, у каждого приложения могут быть уровни запуска, например: нужно что бы программа запустилась в 10 в очереди скриптов, то есть, 
во время загрузки системы, система сначала запустит 1, затем 2, 3, 4 и т.д., наша программа запуститься 10. Так же есть очередь на остановку.
Эти параметры передаются в chkconfig.

Напишем простой скрипт который скажем будет запускать процесс sshd (SSH Server) в фоном режиме.

```> touch service && chmod +x service && echo '#!/bin/bash' >> service```

Немного пояснений, в строке выше мы сначала создали файл service затем назначили ему права на запуск от лица любого пользователя и добавили
в конец (а по факту в начало) файла строку вызова интерпретатора BASH. Далее откройте файл на редактирование в своем любимом текстовом редакторе
и внесите следующие строки:

```
# chkconfig: - 10 05
# description:  Описание процесса
# processname: Имя процесса
```

В первой строке мы объявляем как раз те самые заветные цифры запуска скрипта, то есть он запуститься 10-м в очереди, и будет остановлен 5-м.
Далее описание процесса и собственно имя процесса. Заполняйте поля по своим требованиям. В данном примере мы рассматриваем sshd.

У нас должно получиться следующее:

```
#!/bin/bash
# chkconfig: - 10 05
# description: SSH Server
# processname: sshd
```

Далее зададим несколько переменных, а именно название процесса и рабочая директория процесса.

```
SRVNAME="sshd"
SRVDIR="/usr/sbin"
```

Для того что бы нам было удобнее перенастраивать скрипт на другие процессы и непосредственно для работы самого скрипта когда нам потребуется узнать
информацию о процессе, далее узнаем запущен ли процесс и какой у него pid. О том что такое pid процесса более подробно почитайте на вики.
Добавляем следующие строки (обратите внимание на кавычки, это важно.):

```
SRVPID=`ps aux | grep ${SRVNAME} | grep -v grep | awk {'print $2'}`
SRVSTATUS=`ps aux | grep ${SRVNAME} | grep -v grep`
```

Что мы сделали? В первой строке мы вывели все процессы в системе, далее отсеяли только строку с именем процесса и получили её pid. В итоге переменная
SRVPID приняла значение, а именно номер pid. Вторая строка приняла значение полного параметра строки. Для отладки этих процессов мы можете непосредственно
в терминале запускать данные команды как есть, заменяя ${SRVNAME} на имя нужного процесса, например:

```
ps aux | grep sshd | grep -v grep | awk {'print $2'}
ps aux | grep sshd | grep -v grep
```

Двигаемся далее, почти самое интересное, конструкция условий запуска, выглядит на первый взгляд громоздко, но, когда вы поймете суть, будет довольно просто.
И так, добавьте следующие строки, сохраните и попробуйте запустить:

```
start() {
echo "Run ${SRVNAME}"
}

stop()
{
echo "Stoping ${SRVNAME}"
}

restart()
{
echo "Restarting ${SRVNAME}"
}

status()
{
echo "Status ${SRVNAME}"
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
```
Как видите при первом запуске скрипт ответил: Usage: start|stop|restart|status, то есть для корректной работы вы должны обязательно запускать скрипт с параметром.
Попробуйте запустить с указанными параметрами, в ответ вы будете получать те сообщения, что указаны в скриптке каждой из необходимой секции.
Теперь мы можем усложнить наш скрипт. Я приведу пример и его же приложу в репозиторий, его можно будет изменять под ваши нужды.
Для удобства я добавлю комментарий под каждую строку что вам было более понятно что здесь происходит:

```
#!/bin/bash
# chkconfig: - 10 05
# description: SSH Server
# processname: sshd

SRVNAME="sshd"
SRVDIR="/usr/sbin"

SRVPID=`ps aux | grep ${SRVNAME} | grep -v grep | awk {'print $2'}`
SRVSTATUS=`ps aux | grep ${SRVNAME} | grep -v grep`

# Если мы выбрали start, то запускам программу.
start() {
	
	# Выводим сообщение о запуске программы. Не совсем правильно писать сразу done., т.к. программа может
  # не запуститься по какой-то причине. для этого было бы не плохо дописать ещё одно условие. 
  # Но пока остановимся на этом варианте.
	
	echo "Strating service done."
	cd ${HOMEDIR}
	
	# Запускаем программу и перенаправляем её вывод в никуда, 
  # дабы не засорят экран, так же отправляем её в фоновый режим.
	nohup ${SRVDIR}/${SRVNAME} > /dev/null 2>&1 &
	}

# Если мы выбрали stop, закрываем программу.
# Обратите внимание что в этом пункте есть условие, если pid программы не найден, значит она не запущенна
# и об этом надо сказать пользователю. Если же программа запущена у неё есть pid, завершаем работу программы
# и выводим сообщение об этом.

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

# Если мы выбрали restart, перезапускаем программу.
# Аналогично функции stop, за исключением того, что если pid не найден,
# мы запускаем программу. Если же pid найден, то сначала завершаем программу, 
# далее снова запускаем её.

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

# Аналогично stop, проверяем наличие pid, если он есть отдаем статус программы,
# если его нет пишем сообщение об этом и выходим.

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
```

Собственно на этом все. Переместите данный скрипт в папку /etc/init.d и можно пользоваться. 
Спасибо за внимание.