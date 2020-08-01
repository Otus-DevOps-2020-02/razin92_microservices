create_docker_machine:
		docker-machine create --driver google \
		--google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
		--google-machine-type n1-standard-1 \
		--google-zone europe-west1-b \
		docker-host

remove_docker_machine:
		docker-machine rm docker-host -f

enable_docker_metrics:
		docker-machine scp ./docker/daemon.json docker-host:/tmp && \
		docker-machine ssh docker-host sudo mv /tmp/daemon.json /etc/docker/ && \
		docker-machine ssh docker-host sudo systemctl restart docker

disable_docker_metrics:
		docker-machine ssh docker-host sudo rm /etc/docker/daemon.json && \
		docker-machine ssh docker-host sudo systemctl restart docker

install_telegraf:
		docker-machine scp -r ./monitoring/telegraf/ docker-host:/tmp && \
		docker-machine ssh docker-host sudo /tmp/telegraf/install_telegraf.sh && \
		docker-machine ssh docker-host sudo cp /tmp/telegraf/telegraf.conf /etc/telegraf/ && \
		sleep 5s && \
		docker-machine ssh docker-host sudo systemctl restart telegraf

up_reddit:
		cd docker && \
		docker-compose up -d

up_monitoring:
		cd docker && \
		docker-compose -f docker-compose-monitoring.yml up -d

up: up_reddit up_monitoring

down_reddit:
		cd docker && \
		docker-compose down

down_monitoring:
		cd docker && \
		docker-compose -f docker-compose-monitoring.yml down

down:
		cd docker && \
		docker-compose down --remove-orphans

build_ui:
		cd src/ui && bash ./docker_build.sh

build_post:
		cd src/post-py && bash ./docker_build.sh

build_comment:
		cd src/comment && bash ./docker_build.sh

build_reddit_app: build_ui build_post build_comment

build_prometheus:
		cd monitoring/prometheus && \
		docker build -t $${USER_NAME}/prometheus .

build_blackbox:
		cd monitoring/blackbox && \
		docker build -t $${USER_NAME}/blackbox_exporter .

build_alertmanager:
		cd monitoring/alertmanager && \
		docker build -t $${USER_NAME}/alertmanager .

build_monitoring: build_prometheus build_blackbox build_alertmanager

build_reddit_app_m: build_reddit_app build_monitoring

push_ui:
		docker push $${USER_NAME}/ui

push_post:
		docker push $${USER_NAME}/post

push_comment:
		docker push $${USER_NAME}/comment

push_reddit_app: push_ui push_post push_comment

push_prometheus:
		docker push $${USER_NAME}/prometheus

push_blackbox:
		docker push $${USER_NAME}/blackbox_exporter:latest

push_alertmanager:
		docker push $${USER_NAME}/alertmanager

push_monitoring: push_prometheus push_blackbox

push_reddit_app_m: push_reddit_app push_monitoring
