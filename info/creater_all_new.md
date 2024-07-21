## Расширенный bash-скрипт new

### Bash

```
#!/bin/bash

# Промпт для выбора действия
echo "Выберите действие: "
echo "1) Полная пересборка (с удалением старых контейнеров и созданием новых)"
echo "2) Перезапуск (только перезапуск контейнеров)"
read -p "Введите 1 или 2: " ACTION

# Папки проекта
PROJECT_DIR="$(pwd)"
SOURCE_GENERATOR="$PROJECT_DIR/source_generator"
SOURCE_USER="$PROJECT_DIR/source_user"
DATA_GENERATOR="$PROJECT_DIR/datagenerator"
DATA_USER="$PROJECT_DIR/datauser"

# Функция для проверки и создания папок
create_folder() {
  local folder="$1"
  if [ ! -d "$folder" ]; then
    echo "Create folder $folder"
    mkdir -p "$folder"
  else
    echo "Folder $folder already exists"
  fi
}

# Функция для копирования файлов
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

# Функция для создания Docker сетей
create_network() {
  local network_name="$1"
  if ! docker network ls --filter name="$network_name" --format "{{ .Name }}" | grep -q "$network_name"; then
    echo "Create Docker network $network_name"
    docker network create "$network_name"
  else
    echo "Docker network $network_name already exists"
  fi
}

# Функция для остановки и удаления контейнеров
cleanup_containers() {
  local containers=("data_user" "data_generator" "my_mongo")

  for container in "${containers[@]}"; do
    if docker ps -q --filter name="$container" | grep -q .; then
      echo "Stopping container $container"
      docker stop "$container"
    fi
    if docker ps -a -q --filter name="$container" | grep -q .; then
      echo "Removing container $container"
      docker rm "$container"
    fi
  done
}

# Функция для пересборки и запуска контейнеров
build_and_run() {
  # Создание папок
  create_folder "$DATA_GENERATOR"
  create_folder "$DATA_USER"

  # Копирование файлов
  copy_files "$SOURCE_GENERATOR" "$DATA_GENERATOR"
  copy_files "$SOURCE_USER" "$DATA_USER"

  # Создание Docker сетей
  create_network "net_gen_db"
  create_network "net_db_user"

  # Построение Docker образов
  cd "$DATA_GENERATOR" && docker build -t data_generator . && cd "$PROJECT_DIR"
  cd "$DATA_USER" && docker build -t data_user . && cd "$PROJECT_DIR"

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
}

# Функция для перезапуска контейнеров
restart_containers() {
  cleanup_containers
  build_and_run
}

# Выполнение выбранного действия
case $ACTION in
  1)
    build_and_run
    ;;
  2)
    restart_containers
    ;;
  *)
    echo "Неверный выбор. Пожалуйста, введите 1 или 2."
    exit 1
    ;;
esac

# Открытие терминалов для логов (настраивается под вашу ОС)
gnome-terminal -- docker logs -f data_generator
gnome-terminal -- docker logs -f data_user

echo "Setup complete. Check the new terminal windows for logs."
```

### Описание

**Промпт для выбора действия:**
        Скрипт спрашивает пользователя, нужно ли полное пересборку или просто перезапуск контейнеров.

**Функции:**
       - create_folder проверяет наличие и создает папки.
       - copy_files копирует файлы из исходных папок в целевые папки.
       - create_network проверяет и создает Docker сети.
       - cleanup_containers останавливает и удаляет контейнеры.
       - build_and_run строит Docker образы и запускает контейнеры.
       - restart_containers выполняет полное очищение и пересборку контейнеров.

**Выбор действия и выполнение:**
        В зависимости от выбора пользователя, скрипт либо выполняет полное пересборку, либо просто перезапускает контейнеры.

**Открытие терминалов для логов:**
        Используется gnome-terminal для открытия новых окон терминала и отображения логов.
