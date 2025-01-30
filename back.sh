#!/bin/bash

# Директория для хранения бэкапов (в корневой файловой системе)
BACKUP_DIR="/archive"
# Имя файла бэкапа (с текущей датой)
BACKUP_NAME="backup_$(date +%Y-%m-%d_%H-%M-%S).tar.gz"
# Директории и файлы для резервного копирования
BACKUP_SOURCES=(
    "/home"
    "/etc/ssh"
    "/etc/xrdp"
    "/etc/vsftpd.conf"
    "/var/log"
)
# Максимальное количество хранимых резервных копий
MAX_BACKUPS=5

# Создание директории для бэкапов, если её нет
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Создание директории $BACKUP_DIR..."
    sudo mkdir -p "$BACKUP_DIR"
    sudo chown $USER:$USER "$BACKUP_DIR"  # Даём права текущему пользователю
fi

# Создание архива с отображением процесса
echo "Создание резервной копии..."
sudo tar -czvf "$BACKUP_DIR/$BACKUP_NAME" \
    --exclude="*.sock" \
    --exclude="*.cache*" \
    --exclude="/home/an/thinclient_drives" \
    "${BACKUP_SOURCES[@]}" 2>/dev/null

# Проверка успешности создания архива
if [ $? -eq 0 ]; then
    echo "Резервная копия успешно создана: $BACKUP_DIR/$BACKUP_NAME"
else
    echo "Ошибка при создании резервной копии!"
    exit 1
fi

# Удаление старых резервных копий, если их больше MAX_BACKUPS
echo "Проверка количества резервных копий..."
BACKUP_FILES=("$BACKUP_DIR"/backup_*.tar.gz)
BACKUP_COUNT=${#BACKUP_FILES[@]}

if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
    echo "Удаление старых резервных копий..."
    # Сортировка файлов по дате (от старых к новым)
    SORTED_FILES=($(ls -t "$BACKUP_DIR"/backup_*.tar.gz | tail -n +$(($MAX_BACKUPS + 1))))
    for FILE in "${SORTED_FILES[@]}"; do
        echo "Удаление: $FILE"
        rm "$FILE"
    done
fi

echo "Готово! Текущее количество резервных копий: $(ls "$BACKUP_DIR"/backup_*.tar.gz | wc -l)"