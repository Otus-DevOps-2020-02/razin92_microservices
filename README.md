[![Build Status](https://travis-ci.com/Otus-DevOps-2019-08/razin92_microservices.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2019-08/razin92_microservices)

# razin92_microservices

Репозиторий для работы над домашними заданиями в рамках курса **"DevOps практики и инструменты"**

**Содрежание:**
<a name="top"></a>
1. [ДЗ#12 - Технология контейнеризации. Введение в Docker](#hw12)
2. [ДЗ#13 - Docker-образы. Микросервисы](#hw13)
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
