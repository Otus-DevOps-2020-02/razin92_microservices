#! /bin/sh
# Регистрация нового GitlabRunner
 
 docker exec -it gitlab-runner gitlab-runner register \
 --run-untagged \
 --locked=false \
 --url=http://$(docker-machine ip gitlab-ci)/ \
 --executor=docker \
 --docker-image=alpine:latest
