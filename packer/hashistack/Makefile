ts := $(shell /bin/date "+%s")

check-variables:
ifndef PROJECT
  $(error PROJECT is undefined)
endif
ifndef STACK_VERSION
  $(error STACK_VERSION is undefined)
endif
ifndef NOMAD_VERSION
  $(error NOMAD_VERSION is undefined)
endif
ifndef VAULT_VERSION
  $(error VAULT_VERSION is undefined)
endif
ifndef TERRAFORM_VERSION
  $(error TERRAFORM_VERSION is undefined)
endif
ifndef CONSUL_VERSION
  $(error CONSUL_VERSION is undefined)
endif

build: check-variables
	packer build \
		-var 'project_id=${PROJECT}' \
		-var 'stack_version=${STACK_VERSION}' \
		-var 'nomad_version=${NOMAD_VERSION}' \
		-var 'vault_version=${VAULT_VERSION}' \
		-var 'terraform_version=${TERRAFORM_VERSION}' \
		-var 'consul_version=${CONSUL_VERSION}' \
		packer.json

force-build: check-variables
	packer build -force \
		-var 'project_id=${PROJECT}' \
		-var 'stack_version=${STACK_VERSION}' \
		-var 'nomad_version=${NOMAD_VERSION}' \
		-var 'vault_version=${VAULT_VERSION}' \
		-var 'terraform_version=${TERRAFORM_VERSION}' \
		-var 'consul_version=${CONSUL_VERSION}' \
		packer.json
