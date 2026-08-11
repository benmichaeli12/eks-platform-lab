PLATFORM  := environments/dev/platform
BOOTSTRAP := environments/dev/cluster-bootstrap

.PHONY: fmt validate plan up down stop-db kubeconfig

fmt:
	terraform fmt -recursive

validate:
	terraform -chdir=$(PLATFORM) init -backend=false
	terraform -chdir=$(PLATFORM) validate

plan:
	terraform -chdir=$(PLATFORM) init
	terraform -chdir=$(PLATFORM) plan

up:
	terraform -chdir=$(PLATFORM) init
	terraform -chdir=$(PLATFORM) apply
	terraform -chdir=$(BOOTSTRAP) init
	terraform -chdir=$(BOOTSTRAP) apply

down:
	-terraform -chdir=$(BOOTSTRAP) destroy -auto-approve
	terraform -chdir=$(PLATFORM) destroy -auto-approve

kubeconfig:
	aws eks update-kubeconfig --name $$(terraform -chdir=$(PLATFORM) output -raw cluster_name) --region us-east-1