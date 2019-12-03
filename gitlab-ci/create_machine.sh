docker-machine create --driver google \
 --google-machine-image https://www.googleapis.com/compute/v1/projects/ubuntu-os-cloud/global/images/family/ubuntu-1604-lts \
 --google-machine-type n1-standard-1 \
 --google-zone europe-west1-b \
 --google-disk-size 75 \
 --google-tags http-server \
 gitlab-ci

docker-machine env gitlab-ci

pause 5

eval $(docker-machine env gitlab-ci)

cd ./ansible 
ansible-playbook ./playbooks/gitlab_env.yml
