#!/bin/bash
# Исходная директория для поиска логов.
ROOT_PATH="/opt/webapps"

# Конечная директория для архива
ARCH_PATH="/store/"

# Начало обработки цикла для файлов, ищем в каталоге все файлы с раширением .log
# и выполняем действия для каждого файла, пока цикл не будет завершен.
for FILES in `sudo find ${ROOT_PATH} -name "*.log"`
	do
	# Получаем короткое имя файла. Только имя файла, без директории.
	FILENAME=`echo ${FILES} | awk -F '/' '{print $NF}'`
	# Получаем только название директории в которой находиться файл.
	DIRNAME=`dirname ${FILES} | tr -d ' ' | cut -d '/' -f4`

	# Проверяем наличие конечной директоии аналогично исходной,
	# в директории назначения. Что бы имена папок совпадали с исходной точкой
	# для удобства поиска необходимых копий файлов.
	# Если директория не найдена - создаем ее.
	if [ ! -d "${ARCH_PATH}${DIRNAME}" ]; then
	sudo mkdir ${ARCH_PATH}${DIRNAME}
	fi

	# Проверяем не занят ли в данный момент необходимый файл и если нет,
	# архивируем его.
	FILEBUSY=`sudo lsof ${FILES} | wc -l`
	if [ ${FILEBUSY} -le 0 ]; then
	zip -9 -q ${ARCH_PATH}${DIRNAME}/${FILENAME}.zip ${FILES}
	fi

	# Конец цикла обработки.
	done
