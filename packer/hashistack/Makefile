ts := $(shell /bin/date "+%s")

check-variables:
ifndef PROJECT
  $(error PROJECT is undefined)
endif
ifndef STACK_VERSION
  $(error STACK_VERSION is undefined)
endif

build: check-variables
	packer build \
		-var 'project_id=${PROJECT}' \
		-var 'stack_version=${STACK_VERSION}' \
		packer.json

force-build: check-variables
	packer build -force \
		-var 'project_id=${PROJECT}' \
		-var 'stack_version=${STACK_VERSION}' \
		packer.json
