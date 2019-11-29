[![Build Status](https://travis-ci.com/Otus-DevOps-2019-08/razin92_microservices.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2019-08/razin92_microservices)

# razin92_microservices

Репозиторий для работы над домашними заданиями в рамках курса **"DevOps практики и инструменты"**

**Содрежание:**
<a name="top"></a>
1. [ДЗ#12 - Технология контейнеризации. Введение в Docker](#hw12)
2. [ДЗ#13 - Docker-образы. Микросервисы](#hw13)
3. [ДЗ#14 - Docker: сети, docker-compose](#hw14)
---
<a name="hw12"></a> 
# Домашнее задание 12
## Технология контейнеризации. Введение в Docker

### Namespaces
- **PID** - изоляция процессов. Нумерация с 1. При уничтожении умерает весь namespace
- **mnt** - точки монтирования
- **net** - изоляция сети
- **utc** - hostname, domain name
- **IPC** - коммуникация между процессами
- **user** - изоляция UID и GID 

**Команды:**
- `docker info` - информация о приложении
- `docker ps` - список запущенных контейнеров
- `docker ps -a` - список всех контейнеров
- `docker ps -q` - ID только запущенных контейнеров
- `docker images` - список сохраненных контейнеров
- `docker run <image>` - запуск контейнера из образа (`docker crate` + `docker start` + `docker attach`)
- `docker run -d --network=<name> <image_name>` - запуск контейнера с определенной сетью
- `docker start <container_id>` - запуск созданного контейнера
- `docker attach <container_id>` - подключение терминала к контейнеру
- `docker create` - создание контейнера без запуска
- `docker inspect <object_id>` - вывод конфигурации объекта docker'a
- `docker kill` - посылает SIGKILL (безусловное завершение процесса)
- `docker stop` - посылает SIGTERM (сигнал остановки приложения), через 10 сек SIGKILL
- `docker system df` - отображение занятого пространства объектами docker'a
- `docker rm` - удаляет указанные контейнеры, `-f` если контйнер запущен
- `docker rmi` - удаляет образ, если от него не зависят запущенные контейнеры
- `docker exec` - выполнение команд внутри контейнера
- `docker logs` - просмотр логов
- `docker diff` - различия между контейнером и образом
- `docker volume create <name>` - создание раздела для docker. В последствии, может быть одновременно использован несколькими контейнарми
- `docker volume ls` - список всех разделов
- `docker run -v <name>:/target/path` - использование раздела
- `docker build --tag <name> .` - сброка образа на основе Dockerfile 
- `docker network create <name>` - создание сети для контейнеров
- `docker network create <name> --driver <driver_type>` - с определенным драйвером, по умолчанию - bridge
- `docker network connect <network_name> <container_name>` - подключение дополнительной сети к контейнеру

Примеры `docker run`
```
docker run --rm -it ubuntu:16.04 bash
docker run -dt nginx:latest
docker run --rm --pid host -ti tehbilly/htop

# -i - запуск контейнера в foreground (docker attach)
# -d - запуск контейнера в background
# -t - создает TTY
# --rm - удаляет контейнер при выходе из него
# --pid host - запуск контейнера в определенном PID namespace
```

## Docker-контейнеры
`docker-image` - инструмент для создания хостов и установки на них `docker-engine`

Создание:
```
docker-machine create <name>

# Создания инстанса в GCE
docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 docker-host
```
При создании инстанса в GCE с помощью `docker-machine` используется переменная окружения `GOOGLE_PROJECT` для указания управляемого проекта. 

Для подключения к инстансу выполнить следующие команды:
```
docker-machine env <instance_name>
eval "$(docker-machine env <instance_name>)"
```


[Содержание](#top)
<a name="hw13"></a> 
# Домашнее задание 13
## Docker-образы. Микросервисы

[Написание Dockerfile](https://docs.docker.com/engine/reference/builder/)

При сборке `image` из одинакового базового образа первая команда `build` кеширует его, а последующие уже будут собираться не с первого шага.

## 1 Задание со *
Для запуска контейнеров с определенной переменной окружения применяется ключ `--env`. Для указания нескольких переменных, указывается либо файл со значениями, либо несколько таких ключей.

Пример:
```
docker run -d --network=reddit2 -p 9292:9292 --env POST_SERVICE_HOST=post2 --env COMMENT_SERVICE_HOST=comment2 razin92/ui:1.0
```
## 2 Задание со *
Уменьшение размера образа контейнера.
### UI
```
# Dockerfile.3
# Использование образа Alpine с Ruby

FROM ruby:2.2-alpine
RUN apk update && apk add --virtual build-base
...

# Итоговый размер: 307MB
```
```
# Dockerfile.4
# Удаление инструментов для сброки после самой сборки приложения

FROM ruby:2.2-alpine
...
RUN apk update && \
    apk add --virtual build-base && \
    bundle install &&\
    apk del build-base
...

# Итоговый размер: 159MB
```
### Comment
Оптимизация как и в UI

Итоговый размер: 157MB

[Содержание](#top)
<a name="hw14"></a> 
# Домашнее задание 14
## Docker: сети, docker-compose

Типы сетей в Docker:
- none - только loobback, сеть изолирована
- host - использует сеть хоста
- bridge - отдельные namespaces сети ("виртуальная" сеть)
- MacVlan - на основе сабинтерфейсов Linux, поддерка 802.1Q
- Overlay - несколько Docker хостов в одну сеть, работает поверх VXLAN

При запуске контейнера можно указать только одну сеть параметром `--network=<name>`. Для подключения дополнительных сетей к контейнерам применить команду: `docker network connect`. Также несколько сетей могут быть подключены к контейнеру при запуске, если используется `docker-compose`.

[Документация Docker-compose](https://docs.docker.com/compose/)

Docker-compose позволяет запускать сразу несколько контейнеров по заданному сценарию.

Пример:
```
# docker-compose.yml

version: '3.3'
services:
  post_db:
    image: mongo:${MONGO_VERSION}
    volumes:
      - post_db:/data/db
    networks:
      - reddit
  ui:
    build: ./ui
    image: ${USERNAME}/ui:${UI_VERSION}
    ports:
      - ${UI_PORT}:${REDDIT_PORT}/tcp
    networks:
      - ui
  post:
    build: ./post-py
    image: ${USERNAME}/post:${POST_VERSION}
    networks:
      - reddit
      - ui
  comment:
    build: ./comment
    image: ${USERNAME}/comment:${COMMENT_VERSION}
    networks:
      - reddit
      - ui

volumes:
  post_db:

networks:
  reddit:
  ui:
```
Значения переменных подставляется или из переменных окружения или из файла `.env`. Имя проекта `docker-compose` присваивается от имени директории, в котором он располагается. Для переопределения этого имени используется параметр `-p` или переменная `COMPOSE_PROJECT_NAME`.
```
# .env

COMPOSE_PROJECT_NAME=my_project
MONGO_VERSION=3.2
USERNAME=some_user
UI_VERSION=1.0
POST_VERSION=1.0
COMMENT_VERSION=1.0
UI_PORT=9292
REDDIT_PORT=9292
```
## Задание со *
`docker-compose.ovveride.yml` позволяет перезаписывать параметры `docker-compose.yml`. Для использования модифицированного кода приложений без пересборки образа можно использовать `volumes`. Для перезаписи команды запуска контейнера используется параметр `entrypoint`.
```
# docker-compose.ovveride.yml

version: '3.3'
services:
  ui:
    volumes:
      - ui:/app
    entrypoint: 
      - puma
      - --debug 
      - -w 2
  post:
    volumes:
      - post-py:/app
  comment:
    volumes:
      - comment:/app
    entrypoint: 
      - puma
      - --debug 
      - -w 2

volumes:
  ui:
  post-py:
  comment:
```
