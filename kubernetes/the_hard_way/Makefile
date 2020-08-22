# GCP
create_kub_thw_networks:
		gcloud compute networks create kubernetes-the-hard-way --subnet-mode custom

create_kub_thw_subnets:
		gcloud compute networks subnets create kubernetes \
  			--network kubernetes-the-hard-way \
  			--range 10.240.0.0/24

create_kub_thw_internal_frwl:
		gcloud compute firewall-rules create kubernetes-the-hard-way-allow-internal \
  			--allow tcp,udp,icmp \
  			--network kubernetes-the-hard-way \
  			--source-ranges 10.240.0.0/24,10.200.0.0/16

create_kub_thw_external_frwl:
		gcloud compute firewall-rules create kubernetes-the-hard-way-allow-external \
  			--allow tcp:22,tcp:6443,icmp \
  			--network kubernetes-the-hard-way \
  			--source-ranges 0.0.0.0/0

list_frwl:
		gcloud compute firewall-rules list --filter="network:kubernetes-the-hard-way"

create_public_ip:
		gcloud compute addresses create kubernetes-the-hard-way \
			--region=europe-west1

list_public_ip:
		gcloud compute addresses list --filter="name=('kubernetes-the-hard-way')"

create_kub_controllers:
		for i in 0 1 2; do \
			gcloud compute instances create controller-$$i \
				--async \
				--boot-disk-size 200GB \
				--can-ip-forward \
				--image-family ubuntu-2004-lts \
				--image-project ubuntu-os-cloud \
				--machine-type e2-standard-2 \
				--private-network-ip 10.240.0.1$$i \
				--scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
				--subnet kubernetes \
				--tags kubernetes-the-hard-way,controller ; \
		done

create_kub_workers:
		for i in 0 1 2; do \
			gcloud compute instances create worker-$$i \
				--async \
				--boot-disk-size 200GB \
				--can-ip-forward \
				--image-family ubuntu-2004-lts \
				--image-project ubuntu-os-cloud \
				--machine-type e2-standard-2 \
				--metadata pod-cidr=10.200.$$i.0/24 \
				--private-network-ip 10.240.0.2$$i \
				--scopes compute-rw,storage-ro,service-management,service-control,logging-write,monitoring \
				--subnet kubernetes \
				--tags kubernetes-the-hard-way,worker ; \
			done

list_instances:
		gcloud compute instances list --filter="tags.items=kubernetes-the-hard-way"

install_client_server_cert:
		cd certs/workers && \
		for instance in worker-0 worker-1 worker-2; do \
  			gcloud compute scp ca.pem $$instance-key.pem $$instance.pem $$instance:~/ ; \
		done \

install_sa_cert:
		cd certs/sa && \
		for instance in controller-0 controller-1 controller-2; do \
  			gcloud compute scp ca.pem ca-key.pem kubernetes-key.pem kubernetes.pem \
    		service-account-key.pem service-account.pem $$instance:~/ ; \
		done

install_worker_config:
		cd configs && \
		for instance in worker-0 worker-1 worker-2; do \
  			gcloud compute scp $$instance.kubeconfig kube-proxy.kubeconfig $$instance:~/ ; \
		done

install_controller_config:
		cd configs && \
		for instance in controller-0 controller-1 controller-2; do \
  			gcloud compute scp admin.kubeconfig kube-controller-manager.kubeconfig kube-scheduler.kubeconfig $$instance:~/ ; \
		done

install_ecnryption_config:
		cd encryption && \
		for instance in controller-0 controller-1 controller-2; do\
  			gcloud compute scp encryption-config.yaml $$instance:~/ ; \
		done

delete_instance:
		gcloud -q compute instances delete \
  			controller-0 controller-1 controller-2 \
  			worker-0 worker-1 worker-2 \
  			--zone $$(gcloud config get-value compute/zone)

