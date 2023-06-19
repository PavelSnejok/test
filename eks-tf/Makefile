# Type of the environment variable that you will want to run:
	# For development: environment =  dev.tfvars
	# For production:  environment =  prod.tfvars

ENVIRONMENT = dev.tfvars
include ./module/$(ENVIRONMENT)

# Define AWS profile configuration:
PROFILE = $(shell aws sts get-caller-identity --output text --query 'Account')_Administrator

# Retrieve cluster config from :
REGION := $(shell awk -F' = ' '/^region =/ {gsub(/"/, "", $$2); print $$2}' module/$(ENVIRONMENT))
CLUSTER_NAME := $(shell awk -F' = ' '/^cluster_name =/ {gsub(/"/, "", $$2); print $$2}' module/$(ENVIRONMENT))

# Requires confirmation
target:
	@echo "AWS account number is: $(PROFILE)"
	@echo "Your Region in AWS is: $(REGION)"
	@echo "Cluster name is: $(CLUSTER_NAME)"

	@sh -c ' \
		read -p "Are you sure you want to stop? (yes/no) " answer; \
		if [ "$$answer" = "yes" ]; then \
			echo "Stopping..."; \
			exit 1; \
		elif [ "$$answer" = "no" ]; then \
			echo "Continue..."; \
		else \
			echo "Check your answer"; \
		fi \
	'
# Run the Terraform file to see what resources will be deployed.
plan:
	cd module && terraform init && terraform plan -var-file $(ENVIRONMENT)

# Deploys resources based on the environment. Requires confirmation before proceeding.
apply: target
	cd module && terraform init && terraform apply -var-file $(ENVIRONMENT) -auto-approve

# Removes all resources created based on the environment.
destroy:
	cd module && terraform destroy -var-file $(ENVIRONMENT) -auto-approve

# Updates the kubeconfig file to access the EKS cluster.
config:
	aws eks update-kubeconfig --region $(REGION) --name $(CLUSTER_NAME) --profile $(PROFILE)
