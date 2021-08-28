run: image
	docker run -it --rm \
	-v $(PWD)/packer_cache:/packer/packer_cache \
	-v $(PWD)/images:/var/tmp/images \
	--net=host \
	--device=/dev/kvm \
	--device=/dev/net/tun \
	--cap-add=NET_ADMIN \
	croc:latest

.PHONY: image
image:
	docker build -t croc .

# BEGIN: lint-install .
# http://github.com/tinkerbell/lint-install


HADOLINT_VERSION ?= v2.7.0
SHELLCHECK_VERSION ?= v0.7.2
LINT_OS := $(shell uname)
LINT_ARCH := $(shell uname -m)

# shellcheck and hadolint lack arm64 native binaries: rely on x86-64 emulation
ifeq ($(LINT_OS),Darwin)
	ifeq ($(LINT_ARCH),arm64)
		LINT_ARCH=x86_64
	endif
endif

LINT_LOWER_OS  = $(shell echo $(LINT_OS) | tr '[:upper:]' '[:lower:]')


lint: out/linters/shellcheck-$(SHELLCHECK_VERSION)-$(LINT_ARCH)/shellcheck out/linters/hadolint-$(HADOLINT_VERSION)-$(LINT_ARCH) 
	out/linters/hadolint-$(HADOLINT_VERSION)-$(LINT_ARCH) -t info $(shell find . -name "*Dockerfile")
	out/linters/shellcheck-$(SHELLCHECK_VERSION)-$(LINT_ARCH)/shellcheck $(shell find . -name "*.sh")

out/linters/shellcheck-$(SHELLCHECK_VERSION)-$(LINT_ARCH)/shellcheck:
	mkdir -p out/linters
	curl -sSfL https://github.com/koalaman/shellcheck/releases/download/$(SHELLCHECK_VERSION)/shellcheck-$(SHELLCHECK_VERSION).$(LINT_LOWER_OS).$(LINT_ARCH).tar.xz | tar -C out/linters -xJf -
	mv out/linters/shellcheck-$(SHELLCHECK_VERSION) out/linters/shellcheck-$(SHELLCHECK_VERSION)-$(LINT_ARCH)

out/linters/hadolint-$(HADOLINT_VERSION)-$(LINT_ARCH):
	mkdir -p out/linters
	curl -sfL https://github.com/hadolint/hadolint/releases/download/v2.6.1/hadolint-$(LINT_OS)-$(LINT_ARCH) > out/linters/hadolint-$(HADOLINT_VERSION)-$(LINT_ARCH)
	chmod u+x out/linters/hadolint-$(HADOLINT_VERSION)-$(LINT_ARCH)

# END: lint-install .
