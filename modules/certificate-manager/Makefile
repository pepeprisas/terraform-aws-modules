## [Deploy Service]
## Usage: make deployService DOMAIN=example ENVIRONMENT=staging TEAM=devops COUNTRY=us REGION=us-east-1
deployService:
	@printf "${COLOR_COMMENT}**************************************************${COLOR_RESET}\n"
	@printf "${COLOR_COMMENT}* Deploying Certificate ${DOMAIN} in region ${REGION} *${COLOR_RESET}\n"
	@printf "${COLOR_COMMENT}**************************************************${COLOR_RESET}\n"
	terraform init -reconfigure -backend-config="key=terraform-state/hitrust/${COUNTRY}-${TEAM}-main-${REGION}-${DOMAIN}-ACM-tfstate"
	terraform workspace new ${ENVIRONMENT} || echo true
	terraform workspace select ${ENVIRONMENT}
	terraform plan -var region=${REGION} -var team=${TEAM} -var country=${COUNTRY}
	terraform apply -var region=${REGION} -var team=${TEAM} -var country=${COUNTRY}
	rm -rf .terraform
.PHONY: deployService
