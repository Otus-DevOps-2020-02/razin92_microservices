#! /bin/sh
# Регистрация нового GitlabRunner Docker

docker exec -it gitlab-runner gitlab-runner register \
 --non-interactive \
 --locked=false \
 --url=http://$(docker-machine ip gitlab-ci)/ \
 --executor=shell \
 --docker-image=alpine:latest \
 --tag-list="shell" \
 --description="shell-runner" \
 --registration-token $REGISTRATION_TOKEN
