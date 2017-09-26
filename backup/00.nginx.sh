#!/bin/bash

HOSTNAME="HOSTNAME"
CURRENT_DATE=`date '+%d.%m.%Y'`
NGINX_HOME_DIR="/backup/"
FILE="${HOME_DIR}${CURRENT_DATE}.nginx.tar.bz2"
TG="/etc/telegram/telegram-cli"
TG_NAME="Zabbix_Dev."

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME}  Prepare diroctory and clear old files."

if [ -d ${NGINX_HOME_DIR} ]; then
	sudo find ${NGINX_HOME_DIR} -type f -mtime +1 -print0 | sudo xargs -0 rm -f
else
	sudo mkdir ${NGINX_HOME_DIR}
fi

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Search and copy configuration files of Nginx..."

find /etc/nginx -name '*.conf' -exec cp '{}' ${NGINX_HOME_DIR} \;
cp -r -f /etc/nginx/sites-available/ ${NGINX_HOME_DIR}
cp -r -f /etc/nginx/sites-enabled/ ${NGINX_HOME_DIR}

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Done."

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Starting to archive all configuration files."

tar --exclude=${CURRENT_DATE}.nginx.tar.bz2 --exclude=bin -Ppjcf ${NGINX_HOME_DIR}${CURRENT_DATE}.nginx.tar.bz2 ${NGINX_HOME_DIR}

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Done."

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Removing tempory files."

cd ${NGINX_HOME_DIR}
rm -R -f ${NGINX_HOME_DIR}sites-available/
rm -R -f ${NGINX_HOME_DIR}sites-enabled/
rm -R -f ${NGINX_HOME_DIR}*.conf

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Done."

if [ -f ${FILE} ]; then
        LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
        echo "${LOG_DATETIME} File name: ${FILE}"
        echo "${LOG_DATETIME} File size: `du -sm ${FILE} | cut -f1` Mb"
        TG_TEXT="Хост: ${HOSTNAME} Выполнено резервное копирование конфигурационных файлов Nginx за ${CURRENT_DATE}, размер резервной копии `du -sm ${FILE} | cut -f1` Mb. Файл: ${FILE}"
else
        echo "${LOG_DATETIME} File $FILE does not exist."
        TG_TEXT="Хост: ${HOSTNAME} ВНИМАНИЕ! Сбой при попытке создания резервной копии конфигурационных файлов Nginx. Пожалуйста проверьте сервер."
        exit 0;
fi

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Sending mail report to administrator."
${TG} -k tg-server.pub -D -W -R -e "msg ${TG_NAME} ${TG_TEXT}"

LOG_DATETIME=`date '+%d.%m.%Y %H:%M:%S'`
echo "${LOG_DATETIME} Done."
