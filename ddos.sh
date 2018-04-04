#!/bin/bash

# Задаем рабочую директорию скрипта.
HOMEDIR="/opt"

# Переходим в директорию и собираем все активные соединения с уникальных адресов. Сортируем
# и помещаем список в фалй.
cd ${HOMEDIR}
netstat -ntu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr > ${HOMEDIR}/ip.dat

# Читаем построчно файл, разделяем адрес и количество установленных подключений с него.
while read lines
        do
        ip_count=`echo $lines | awk {'print $1'}`
        ip_addr=`echo $lines | awk {'print $2'}`
        if [ $ip_count -gt "1000" ]
        then
                ip_banned="$ip_addr"

		# Если это соденения с localhost то пропускаем этот арес.
		# Проверяем не занесен ли адрес в таблицу. Если занесен, то игнорирем.
		# Если адреса нет, то вносим его в бан.
                if [ $ip_banned != "127.0.0.1" ]
                then
                        ipt=`iptables -L -v -n | grep "$ip_banned" | wc -l`
                        if [ $ipt -gt "1" ]
                        then
                                echo "$ip_banned all redy in block"
                        else
                                iptables -A INPUT -s $ip_banned  -j DROP
                                iptables -A OUTPUT -d $ip_banned  -j DROP
                        fi
                fi
        fi

done < ${HOMEDIR}/ip.dat
