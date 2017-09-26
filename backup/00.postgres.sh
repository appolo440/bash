#!/bin/bash

HOSTNAME="HOSTNAME"
CURRENT_DATE=`date '+%d.%m.%Y'`
HOME_DIR="/store/postgres/"
FILE="${HOME_DIR}${CURRENT_DATE}.all.databases.sql.zip"
TG="/etc/telegram/telegram-cli"
TG_NAME="Zabbix_Dev."

echo "HOST: ${HOSTNAME}"
LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Removing old date files from directory."

cd ${HOME_DIR}
sudo find ${HOME_DIR} -type f -mtime +1 -print0 | sudo xargs -0 rm -f

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Starting dump all data from Postgres SQL base."
sudo su postgres -c 'pg_dumpall > '${HOME_DIR}${CURRENT_DATE}'.all.databases.sql'

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Job is done, start compressing dump file..."
sudo su postgres -c 'zip -9 -q -m  '${HOME_DIR}${CURRENT_DATE}'.all.databases.sql.zip '${HOME_DIR}${CURRENT_DATE}'.all.databases.sql'

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Remove source file."
cd ${HOME_DIR}
sudo su postgres -c 'rm -f '${HOME_DIR}${CURRENT_DATE}'.all.databases.sql'
echo "${LOG_DATETIME} Done."


if [ -f ${FILE} ]; then
	LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
	echo "${LOG_DATETIME} File name: ${FILE}"
	echo "${LOG_DATETIME} File size: `du -sm ${FILE} | cut -f1` Mb"
	TG_TEXT="Хост: ${HOSTNAME} Выполнено резервное копирование баз данных Postgres за ${CURRENT_DATE}, размер резервной копии `du -sm ${FILE} | cut -f1` Mb. Файл: ${FILE}"
else
        echo "${LOG_DATETIME} File $FILE does not exist."
	TG_TEXT="Хост: ${HOSTNAME} ВНИМАНИЕ! Сбой при попытке создания резервной копии баз данных Postgres. Пожалуйста проверьте сервер."
        exit 0;
fi

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Sending mail report to administrator."
${TG} -k tg-server.pub -D -W -R -e "msg ${TG_NAME} ${TG_TEXT}"

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Done."
