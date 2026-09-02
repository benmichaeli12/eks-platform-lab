PLATFORM  := environments/dev/platform
BOOTSTRAP := environments/dev/cluster-bootstrap

.PHONY: fmt validate plan up down kubeconfig argocd-password argocd-ui stop-db start-db

fmt:
	terraform fmt -recursive

validate:
	terraform -chdir=$(PLATFORM) init -backend=false
	terraform -chdir=$(PLATFORM) validate
	terraform -chdir=$(BOOTSTRAP) init -backend=false
	terraform -chdir=$(BOOTSTRAP) validate
	helm lint gitops/platform --set clusterName=x --set vpcId=y

plan:
	terraform -chdir=$(PLATFORM) init
	terraform -chdir=$(PLATFORM) plan

up:
	terraform -chdir=$(PLATFORM) init
	terraform -chdir=$(PLATFORM) apply
	$(MAKE) kubeconfig
	terraform -chdir=$(BOOTSTRAP) init
	terraform -chdir=$(BOOTSTRAP) apply

down:
	-terraform -chdir=$(BOOTSTRAP) destroy -auto-approve
	terraform -chdir=$(PLATFORM) destroy -auto-approve

kubeconfig:
	aws eks update-kubeconfig --region us-east-1 \
		--name $$(terraform -chdir=$(PLATFORM) output -raw cluster_name)

argocd-password:
	kubectl -n argocd get secret argocd-initial-admin-secret \
		-o jsonpath='{.data.password}' | base64 -d && echo

argocd-ui:
	kubectl -n argocd port-forward svc/argocd-server 8080:80

stop-db:
	aws rds stop-db-instance --db-instance-identifier \
		$$(terraform -chdir=$(PLATFORM) output -raw database_identifier)

start-db:
	aws rds start-db-instance --db-instance-identifier \
		$$(terraform -chdir=$(PLATFORM) output -raw database_identifier)