[![Build Status](https://travis-ci.com/Otus-DevOps-2019-08/razin92_microservices.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2019-08/razin92_microservices)

# razin92_microservices

Репозиторий для работы над домашними заданиями в рамках курса **"DevOps практики и инструменты"**

**Содрежание:**
<a name="top"></a>
1. [ДЗ#12 - Технология контейнеризации. Введение в Docker](#hw12)
---
<a name="hw12"></a> 
# Домашнее задание 12
## Технология контейнеризации. Введение в Docker

Команды:
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

Примеры `docker run`
```
docker run -it ubuntu:16.04 bash
docker run -dt nginx:latest

# -i - запуск контейнера в foreground (docker attach)
# -d - запуск контейнера в background
# -t - создает TTY
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
Создание инстанса в GCE использует переменную окружения `GOOGLE_PROJECT` для 
