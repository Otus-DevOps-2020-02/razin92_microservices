#! /bin/sh
# Регистрация нового GitlabRunner Docker

docker exec -it gitlab-runner gitlab-runner register \
 --non-interactive \
 --run-untagged \
 --locked=false \
 --url=http://$(docker-machine ip gitlab-ci)/ \
 --executor=docker \
 --docker-image=alpine:latest \
 --tag-list="linux,xenial,ubuntu,docker" \
 --description="docker-runner" \
 --registration-token $REGISTRATION_TOKEN
