[![Build Status](https://travis-ci.com/Otus-DevOps-2020-02/razin92_microservices.svg?branch=master)](https://travis-ci.com/Otus-DevOps-2020-02/razin92_microservices)

# razin92_microservices

Репозиторий для работы над домашними заданиями в рамках курса **"DevOps практики и инструменты"**

**Содрежание:**
<a name="top"></a>
1. [ДЗ#12 - Технология контейнеризации. Введение в Docker](#hw12)
2. [ДЗ#13 - Docker-образы. Микросервисы](#hw13)
3. [ДЗ#14 - Docker: сети, docker-compose](#hw14)
4. [ДЗ#15 - Устройство Gitlab CI. Построение процесса непрерывной поставки](#hw15)
5. [ДЗ#16 - Введение в мониторинг. Системы мониторинга](#hw16)
6. [ДЗ#17 - Мониторинг приложения и инфраструктуры](#hw17)

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

[Содержание](#top)
<a name="hw15"></a> 
# Домашнее задание 15
## Устройство Gitlab CI. Построение процесса непрерывной поставки

### Установка и запуск Gitlab-CI в контейнере на GCP

- Создание инстанса при помощи docker-machine
- Запуск контейнера с docker-compose
```
web:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab.example.com'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'http://<YOUR-VM-IP>'
  ports:
    - '80:80'
    - '443:443'
    - '2222:22'
  volumes:
    - '/srv/gitlab/config:/etc/gitlab'
    - '/srv/gitlab/logs:/var/log/gitlab'
    - '/srv/gitlab/data:/var/opt/gitlab'
```

### Краткое описание конфигурации gitlab-ci.yml
```
# образ контейнера по умолчанию
image: ruby:2.4.2
# Стадии конвеера. На каждую стадию может быть несколько джобов
stages:
  - build
  - test
  - review
  - stage
  - production

# Переменные окружения
variables:
  DATABASE_URL: 'mongodb://mongo/user_posts'

# Глобальная задача для джобов, перед их исполнением
before_script:
  - cd reddit
  - bundle install 

# джоб
build_job:
  # Переопределение глобальной задачи перед скриптом
  before_script: 
    - cd docker-monolith
  # Указание стадии  
  stage: build
  # По тегу могут быть запущены определенные раннеры
  tags:
    - shell
  # "тело" джоба
  script:
    - echo "Building Reddit Container"
    - docker build -t $DOCKER_USER/gitlab_hw:$CI_PIPELINE_ID .
    - docker login -u $DOCKER_USER -p $DOCKER_USER_PASSWORD
    - docker push $DOCKER_USER/gitlab_hw:$CI_PIPELINE_ID

test_unit_job:
  stage: test
  services:
    - mongo:latest
  script:
    - ruby simpletest.rb

test_integration_job:
  before_script:
    - echo 'Gcloud testing'
  stage: test
  script:
    - echo 'Testing 2'

deploy_dev_job:
  stage: review
  before_script:
    - echo $GCLOUD_SERVICE_ACCOUNT_KEY > ./$CI_PIPELINE_ID.json
  tags:
    - gcp
  script:
    - echo 'Deploy'
    - gcloud auth activate-service-account --key-file=./$CI_PIPELINE_ID.json
    - gcloud compute ssh gitlab-ci --force-key-file-overwrite --zone $GCP_ZONE --command "sudo docker run --rm -d --name reddit -p 9292:9292 $DOCKER_USER/gitlab_hw:$CI_PIPELINE_ID"
  environment:
    name: dev
    url: http://$CI_SERVER_HOST:9292

branch review:
  stage: review
  script: echo "Deploy to $CI_ENVIRONMENT_SLUG"
  environment:
    name: branch/$CI_COMMIT_REF_NAME
    url: http://$CI_ENVIRONMENT_SLUG.example.com
  only:
    - branches
  except:
    - master

staging:
  stage: stage
  # Условия, при котором запускается джоб
  when: manual # вручную
  only:
    - /^\d+\.\d+\.\d+/ # только если коммит создержит этот тег
  script:
    - echo 'Deploy'
  environment:
    name: stage
    url: https://beta.example.com

production:
  stage: production
  when: manual
  only:
    - /^\d+\.\d+\.\d+/
  script:
    - echo 'Deploy'
  environment:
    name: production
    url: https://example.com

```
### Раннеры
Раннеры - среда исполнения джобов. Исполнители могут быть следующие:
- SSH
- Shell
- Parallels
- VirtualBox
- Docker
- Docker Machine (auto-scaling)
- Kubernetes
- Custom
```
#! /bin/sh
# Установка GitlabRunner

docker run -d --name gitlab-runner --restart always \
-v /srv/gitlab-runner/config:/etc/gitlab-runner \
-v /var/run/docker.sock:/var/run/docker.sock \
-v /usr/bin/docker:/usr/bin/docker \
gitlab/gitlab-runner:latest

```

Раннеры регистрируются на проект при помощи токена.

Пример:
```
#! /bin/sh
# Регистрация нового GitlabRunner Docker Ruby

docker exec -it gitlab-runner gitlab-runner register \
 --non-interactive \
 --run-untagged \  # если стоит этот флаг, то раннер будет запускаться для джобов без тега
 --locked=false \
 --url=http://$(docker-machine ip gitlab-ci)/ \
 --executor=docker \
 --docker-image=ruby:2.4.2 \
 --tag-list="linux,xenial,ubuntu,docker" \
 --description="docker-runner" \
 --registration-token $REGISTRATION_TOKEN
```

### Переменные Gitlab-CI
Встроенные переменные используются для вызова в джобах CI/CD. Также могут быть настроены кастомные переменные для проекта.

### Задания со *
Для создания и регистрации большого количество раннеров можно использовать скрипты вида, указанного выше. Флаг `--non-interactive` отключает вопросы при регистрации раннера. Также требуется указать токен `$REGISTRATION_TOKEN` для привязки к проекту.

Для автоматической сборки, публикации и деплоя контейнера с приложением `reddit-app` я использовал разные раннеры. Для сборки контейнера и его публикации использовался раннер с экзекутором SHELL. Для корректной работы необходимы данные авторизации на DockerHub `DOCKER_USER` и `DOCKER_USER_PASSWORD`. Для деплоя приложения использовал контейнер `google/cloud-sdk:alpine`. Для корректной работы деплоя из Gitlab-CI в GCP требуются следующие данные и настройки:
- Должен быть включен API
- сервис-аккаунт должен обладать необходимыми правами для исполнения комманд на инстансе
- `GCLOUD_SERVICE_ACCOUNT_KEY` ключ сервис-аккаунта
- `GCP_ZONE` зона, в которой находится инстанс

Для интеграции со слаком необходимо в мессанджере настроить кастомную интеграции. Сгенерированный вебхук использовать в настройках GitlabCi в разделе интеграции.

Полезные ссылки:
- [Настройка деплоя в GCP из GitLab](https://medium.com/google-cloud/automatically-deploy-to-google-app-engine-with-gitlab-ci-d1c7237cbe11)
- [Настройка сервис-аккаунта](https://stackoverflow.com/questions/45472882/how-to-authenticate-google-cloud-sdk-on-a-docker-ubuntu-image)

[Содержание](#top)
<a name="hw16"></a>
# Домашнее задание 16
## Введение в мониторинг. Системы мониторинга.

В качестве системы мониторинга будет рассморен `Prometheus`. Просмотр собранных данных возможен через встроенный web-интерфейс. Фильтр и построение отчетов при помощи `PromQL`. Настройка параметров мониторинга задается в файле `.yml`. Метрики могут быть собраны сторонними решениями - экспортерами.

```
# Пример конфигурации
global:
  scrape_interval: '5s'  # Частота сбора метрик

scrape_configs:  # параметры сбора метрик
  - job_name: 'prometheus'
    static_configs:
      - targets:  # цель сбора метрик
        - 'localhost:9090'  # endpoint

  - job_name: 'percona_mongodb'
    static_configs:
    - targets:
        - 'mongodb-exporter:9216' # сторонний сборщик метрик

```

## Задания со *
В качестве экспортера для мониторинга MongoDB был использован [Percona-exporter](https://github.com/percona/mongodb_exporter). Для подключения к MongoDB необходимо указать расположение сервиса в переменной окружения `MONGODB_URI`.

`Blackbox Exporter` используется для проверок сервисов "снаружи". В данной работе был использован модуль HTTP для проверки доступности сервисов.

```
# config file

modules:  # используемые модули
  http_2xx:  # название
    prober: http  # тип опроса
    timeout: 5s  # интервал
    http:
      valid_http_versions: ["HTTP/1.1", "HTTP/2"]
      valid_status_codes: []  # Defaults to 2xx
      method: GET
      preferred_ip_protocol: "ip4"
      ip_protocol_fallback: false
  
```
```
# интеграция в Prometheus

- job_name: 'blackbox'  
  metrics_path: /probe  # путь до метрик 
  params:
    module: 
      - http_2xx
  static_configs:
    - targets:  # цли для опроса
      - 'http://ui:9292/metrics'
      - 'http://comment:9292/metrics'
      - 'http://post-py:5000/metrics'
  relabel_configs:  # настройки отображения
    - source_labels: [__address__]
      target_label: __param_target
    - source_labels: [__param_target]
      target_label: instance
    - target_label: __address__
      replacement: blackbox-exporter:9115

```
```
# пример получаемых метрик

# TYPE probe_http_duration_seconds gauge
probe_http_duration_seconds{phase="connect"} 0.000162122
probe_http_duration_seconds{phase="processing"} 0.001374135
probe_http_duration_seconds{phase="resolve"} 0.000715442
probe_http_duration_seconds{phase="tls"} 0
probe_http_duration_seconds{phase="transfer"} 0.000160417

# TYPE probe_http_version gauge
probe_http_version 1.1

# TYPE probe_http_status_code gauge
probe_http_status_code 200

# TYPE probe_success gauge
probe_success 1

```

Для удобства управления и сборки контейнеров исползован `Makefile`. Использование: `make {имя_операции}`.

```
# пример

build_ui:  # имя операции
		cd src/ui && bash ./docker_build.sh  # операция

build_post:
		cd src/post-py && bash ./docker_build.sh

build_comment:
		cd src/comment && bash ./docker_build.sh

build_reddit_app: build_ui build_post build_comment

```

[Содержание](#top)
<a name="hw17"></a>
# Домашнее задание 17
## Мониторинг приложения и инфраструктуры
