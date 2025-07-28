SHELL=/bin/bash
_ENV?=dev
#Replace Project name value (Sandbox) with actual project name
_PROJECT=lookingglasslifestyle
_PREFIX=$(_PROJECT)-$(_ENV)
_AWS_PROFILE?=$(_PREFIX)
_AWS_REGION=us-east-1
SCRIPTS=infrastructure/scripts
GIT_PROJECT_NAME?=$(shell basename `git rev-parse --show-toplevel`)
GITHUB_SHA?=$(shell git rev-parse HEAD)
TERRAGRUNT_DIR=infrastructure/environments/$(_ENV)/
_AWS_SSO_URL=https://techholding.awsapps.com/start#/
MAKEFLAGS+=--no-print-directory

.EXPORT_ALL_VARIABLES:
TF_VAR_env=$(_ENV)
TF_VAR_prefix=$(_PREFIX)
TF_VAR_repo_name=$(GIT_PROJECT_NAME)
TF_VAR_aws_profile=$(_AWS_PROFILE)
TF_VAR_aws_region=$(_AWS_REGION)
TF_VAR_tf_bucket=$(TF_VAR_prefix)-terraform
TF_VAR_ssm_prefix=/$(_PROJECT)/$(_ENV)

## login into AWS
awscli-configure:
	@aws configure --profile $(TF_VAR_aws_profile)
	
## setup aws profile
awscli-ci:
	@./$(SCRIPTS)/awscli

# To set aws sso login local
# Use: _ENV=dev/qa/prod make awscli-local role=xyz account_id=123456789
awscli-local:
	@./$(SCRIPTS)/awscli_local $(role) $(account_id)

## tfswitch tgswitch
init-upgrade: tf
	@cd $(TERRAGRUNT_DIR) && terragrunt init --upgrade

init plan apply show destroy: tf
	@cd $(TERRAGRUNT_DIR) && terragrunt $@

plan-ci:
	@cd $(TERRAGRUNT_DIR) && terragrunt plan -no-color --terragrunt-forward-tf-stdout

# apply terraform wihtout asking input `yes`
apply-ci:
	@cd $(TERRAGRUNT_DIR) && terragrunt apply -auto-approve

# remove tfstate file lock
rmtflock: tf
	@cd $(TERRAGRUNT_DIR) && terragrunt force-unlock $(lock_id)

# run apply command for targeted resource
tftarget:
	@cd $(TERRAGRUNT_DIR) && terragrunt apply -target $(resource_id)

# show terraform outputs
tfoutput:
	@cd $(TERRAGRUNT_DIR) && terragrunt output --json 2> /dev/null

# validate terraform code
tfvalidate:
	@cd $(shell make init 2>&1 |grep "working directory to" |awk '{print $$8}') && terraform validate

# formating terraform and terragrunt code
tfstate:
	@cd $(TERRAGRUNT_DIR) && terragrunt state list

tfstateshow:
	@cd $(TERRAGRUNT_DIR) && terragrunt state show $(resource_id)

fmt:
	@terraform fmt --recursive
	@terragrunt hclfmt

# import terraform resource
tfimport:
	@cd $(TERRAGRUNT_DIR) && terragrunt import $(tf_resource_id) $(aws_resource_id)

# install/set terraform and terragrunt version
tf:
	@tfswitch
	@tgswitch

tfrmstate: 
	@cd $(TERRAGRUNT_DIR) && terragrunt state rm $(resource_id)

tfmvstate: 
	@cd $(TERRAGRUNT_DIR) && terragrunt state mv $(source_id) $(target_id)

## For secrets envs AWS ssm
## Use: _ENV=dev/qa/prod make putvar path=repo/tpl-infra var=foo=bar
# add terraform vars in aws ssm
putvar:
	@./$(SCRIPTS)/putvar $(TF_VAR_ssm_prefix)/$(path) '$(var)'

getvars:
	@./$(SCRIPTS)/getvars $(TF_VAR_ssm_prefix)/$(path)

terraform-scan:
	@docker run --rm -v /var/run/docker.sock:/var/run/docker.sock -v $(PWD):/tmp/.cache --workdir /tmp/.cache/ aquasec/trivy config /tmp/.cache/infrastructure

db-users:
	@$(eval BASTION_IP=$(shell make tfoutput | jq ".bastion_public_ip.value"))
	@$(eval DB_CREDS=$(shell make tfoutput | jq ".db_creds.value"))
	@$(eval DB_HOST=$(shell echo $(DB_CREDS) | jq -r ".endpoint" | cut -d':' -f1))
	@$(eval DB_NAME=postgres)
	@$(eval DB_USER=$(shell echo $(DB_CREDS) | jq -r ".master_username"))
	@$(eval DB_PASSWORD=$(shell echo $(DB_CREDS) | jq -r  ".master_password"))
	@cd users/db && ansible-playbook  -e "env=$(_ENV) ansible_host=$(BASTION_IP) ansible_ssh_private_key_file=$(ansible_ssh_private_key_file) ansible_user=$(ansible_user) DB_HOST=$(DB_HOST) DB_NAME=$(DB_NAME) DB_USER=$(DB_USER) DB_PASSWORD=$(DB_PASSWORD)" playbook.yml -i inventory

# use: make bastion-users ansible_user=user
bastion-users:
	@$(eval BASTION_IP=$(shell make tfoutput | jq ".bastion_public_ip.value"))
	@cd users/bastion && ansible-playbook  -e "env=$(_ENV) ansible_host=$(BASTION_IP) ansible_ssh_private_key_file=$(ansible_ssh_private_key_file) ansible_user=$(ansible_user)" playbook.yml -i inventory


# Lambda Package and Publish
ZIP_FILES=$(_PREFIX)-dialpad-events-processor.zip
package:
	@rm -rf $(ZIP_FILES)
	@rm -rf postSignupLambda/node_modules
	@cd postSignupLambda \
		&& npm install \
		&& zip -r ../$(_PREFIX)-dialpad-events-processor.zip .

publish:
	@echo "------ Publishing Lambda Artifacts ------"
	@for FILE in $$ZIP_FILES; \
		do echo $$FILE; \
	    aws s3 cp $$FILE s3://$(_PREFIX)-lambda-artifacts/ --metadata '{"source_code_hash":"$(GITHUB_SHA)"}' --profile $(_AWS_PROFILE); \
	done