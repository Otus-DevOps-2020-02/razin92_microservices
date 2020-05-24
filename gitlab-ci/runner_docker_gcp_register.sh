#! /bin/sh
# Регистрация нового GitlabRunner Docker Gcloud

docker exec -it gitlab-runner gitlab-runner register \
 --non-interactive \
 --run-untagged \
 --locked=false \
 --url=http://$(docker-machine ip gitlab-ci)/ \
 --executor=docker \
 --docker-image=google/cloud-sdk:alpine \
 --tag-list="gcp,gcloud" \
 --description="gcloud-runner" \
 --registration-token $REGISTRATION_TOKEN
