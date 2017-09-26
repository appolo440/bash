#!/bin/bash

HOSTNAME="HOST_NAME"
CURRENT_DATE=`date '+%d.%m.%Y'`
HOME_DIR="/backup/"
FILE="${HOME_DIR}${CURRENT_DATE}.home.tar.bz2"
TG="/etc/telegram/telegram-cli"
TG_NAME="Zabbix_Dev."

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "HOST: ${HOSTNAME}"

echo "${LOG_DATETIME} Removing old date files from directory."
sudo find ${HOME_DIR} -type f -mtime +5 -print0 | sudo xargs -0 rm -f

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Done."

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Staring compressing /home directory."

cd /
sudo tar -pjcf ${HOME_DIR}${CURRENT_DATE}.home.tar.bz2 home

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Done."

if [ -f ${FILE} ]; then
	LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
	echo "${LOG_DATETIME} File name: ${FILE}"
	echo "${LOG_DATETIME} File size: `du -sm ${FILE} | cut -f1` Mb"
	TG_TEXT="Хост: ${HOSTNAME} Выполнено резервное копирование директории /home за ${CURRENT_DATE}, размер резервной копии `du -sm ${FILE} | cut -f1` Mb. Файл: ${FILE}"
else
	echo "${LOG_DATETIME} File $FILE does not exist."
	TG_TEXT="Хост: ${HOSTNAME} ВНИМАНИЕ! Сбой при попытке создания резервной копии директории /home. Пожалуйста проверьте сервер."
	exit 0;
fi

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Sending report to administrator."
${TG} -k tg-server.pub -D -W -R -e "msg ${TG_NAME} ${TG_TEXT}"

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Done."