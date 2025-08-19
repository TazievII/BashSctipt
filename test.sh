#!/bin/bash
URL="${2:-https://raw.githubusercontent.com/GreatMedivack/files/master/list.out}"
FILENAME=${1:-NotSet}_$(date +%d_%m_%Y)
wget $URL
grep -E "Error|CrashLoopBackOff" list.out | awk '{sub(/-[^-]*-[a-z0-9]{5}$/, "", $1); sub(/-[0-9]+$/, "", $1); print $1}' > ${FILENAME}_failed.out
grep -E "Running" list.out | awk '{sub(/-[^-]*-[a-z0-9]{5}$/, "", $1); sub(/-[0-9]+$/, "", $1); print $1}' > ${FILENAME}_running.out
RUNNING_COUNT=$(wc -l < ${FILENAME}_running.out)
FAILED_COUNT=$(wc -l < ${FILENAME}_failed.out)
USERNAME=$(whoami)
CURRENT_DATE=$(date +%d/%m/%y)
cat > ${FILENAME}_report.out << EOF
Количество работающих сервисов: $RUNNING_COUNT
Количество сервисов с ошибками: $FAILED_COUNT
Имя системного пользователя: $USERNAME
Дата: $CURRENT_DATE
EOF
mkdir -p archives
ARCHIVENAME=${FILENAME}.tar
if [ ! -f "archives/${ARCHIVENAME}" ]; then
        tar -czf archives/${ARCHIVENAME} ${FILENAME}_failed.out ${FILENAME}_running.out ${FILENAME}_report.out
        rm -f ${FILENAME}_running.out ${FILENAME}_failed.out ${FILENAME}_report.out list.out
        echo "Архив создан"
else
        rm -f ${FILENAME}_running.out ${FILENAME}_failed.out ${FILENAME}_report.out list.out
        echo "Архив с именем ${ARCHIVENAME} уже существует"
fi
echo "Файлы сохранены"
