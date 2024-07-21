## Расширенный bash-скрипт

### Этот скрипт будет:

   * **Проверять наличие и создавать папки.**
   * **Копировать <файлы>.py и Dockerfile в нужные папки.**
   * **Создавать Docker-образы и запускать контейнеры.**
   * **Открывать новые терминалы для отображения логов (это зависит от вашей операционной системы и может потребовать специфичных команд).**

### Пример скрипта

    bash

```
#!/bin/bash

# Создание папок проекта
PROJECT_DIR="$(pwd)"
SOURCE_GENERATOR="$PROJECT_DIR/source_generator"
SOURCE_USER="$PROJECT_DIR/source_user"
DATA_GENERATOR="$PROJECT_DIR/datagenerator"
DATA_USER="$PROJECT_DIR/datauser"

echo "Create folder source_generator if not exists"
mkdir -p "$SOURCE_GENERATOR"

echo "Create folder source_user if not exists"
mkdir -p "$SOURCE_USER"

echo "Create folder datagenerator if not exists"
mkdir -p "$DATA_GENERATOR"

echo "Create folder datauser if not exists"
mkdir -p "$DATA_USER"

# Проверка и копирование файлов *.py и Dockerfile
copy_files() {
  local src_dir="$1"
  local dest_dir="$2"
  local files=("*.py" "Dockerfile")

  for file in "${files[@]}"; do
    if ls "$src_dir/$file" 1> /dev/null 2>&1; then
      echo "Copying $file from $src_dir to $dest_dir"
      cp "$src_dir/$file" "$dest_dir/"
    else
      echo "$file not found in $src_dir"
    fi
  done
}

copy_files "$SOURCE_GENERATOR" "$DATA_GENERATOR"
copy_files "$SOURCE_USER" "$DATA_USER"

# Создание Docker сетей
NET_GEN_DB_EXISTS=$(docker network ls --filter name=net_gen_db --format "{{ .Name }}")
if [ "$NET_GEN_DB_EXISTS" != "net_gen_db" ]; then
  echo "Create Docker network net_gen_db"
  docker network create net_gen_db
else
  echo "Docker network net_gen_db already exists"
fi

NET_DB_USER_EXISTS=$(docker network ls --filter name=net_db_user --format "{{ .Name }}")
if [ "$NET_DB_USER_EXISTS" != "net_db_user" ]; then
  echo "Create Docker network net_db_user"
  docker network create net_db_user
else
  echo "Docker network net_db_user already exists"
fi

# Построение Docker образов
cd "$DATA_GENERATOR"
docker build -t data_generator .
cd "$PROJECT_DIR"

cd "$DATA_USER"
docker build -t data_user .
cd "$PROJECT_DIR"

# Запуск контейнеров
docker run --name my_mongo \
           --network net_gen_db \
           --network-alias mongo_gen \
           --network net_db_user \
           --network-alias mongo_user \
           -v mongo_data:/data/db \
           -d mongo:latest

docker run --name data_generator \
           --network net_gen_db \
           --depends_on my_mongo \
           -d data_generator

docker run --name data_user \
           --network net_db_user \
           --depends_on my_mongo \
           -d data_user

# Открытие терминалов для логов (возможно, потребуется настройка в зависимости от ОС)
gnome-terminal -- docker logs -f data_generator
gnome-terminal -- docker logs -f data_user

echo "Setup complete. Check the new terminal windows for logs."
```

### Описание

    **Создание папок и проверка файлов:**
        Создает папки, если они не существуют.
        Копирует файлы *.py и Dockerfile из source_generator и source_user в datagenerator и datauser соответственно.

    **Создание Docker сетей:**
        Проверяет наличие сетей и создает их, если они отсутствуют.

    **Построение и запуск контейнеров:**
        Создает Docker образы для генератора и пользователя данных.
        Запускает контейнеры и монтирует volume для хранения данных MongoDB.

    **Открытие терминалов для логов:**
        Использует gnome-terminal для открытия новых окон терминала и отображения логов.
        Замените на подходящую команду для вашей ОС, если нужно.
