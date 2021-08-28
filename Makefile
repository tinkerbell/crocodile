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

# BEGIN: lint-install ../crocodile/
# http://github.com/tinkerbell/lint-install


HADOLINT_VERSION ?= v2.7.0
SHELLCHECK_VERSION ?= v0.7.2
LINT_OS := $(shell uname)
LINT_ARCH := $(shell uname -m)

# shellcheck and hadolint don't have arm64 native binaries: use Rosetta instead
ifeq ($(LINT_OS),Darwin)
	ifeq ($(LINT_ARCH),arm64)
		LINT_ARCH=x86_64
	endif
endif

LINT_LOWER_OS  = $(shell echo $(LINT_OS) | tr '[:upper:]' '[:lower:]')


lint: out/linters/shellcheck-$(SHELLCHECK_VERSION)/shellcheck out/linters/hadolint-$(HADOLINT_VERSION) 
	out/linters/hadolint-$(HADOLINT_VERSION) -t info $(shell find . -name "*Dockerfile")
	out/linters/shellcheck-$(SHELLCHECK_VERSION)/shellcheck $(shell find . -name "*.sh")

out/linters/shellcheck-$(SHELLCHECK_VERSION)/shellcheck:
	mkdir -p out/linters
	curl -sfL https://github.com/koalaman/shellcheck/releases/download/v0.7.2/shellcheck-$(SHELLCHECK_VERSION).$(LINT_LOWER_OS).$(LINT_ARCH).tar.xz | tar -C out/linters -xJf -

out/linters/hadolint-$(HADOLINT_VERSION):
	mkdir -p out/linters
	curl -sfL https://github.com/hadolint/hadolint/releases/download/v2.6.1/hadolint-$(LINT_OS)-$(LINT_ARCH) > out/linters/hadolint-$(HADOLINT_VERSION)
	chmod u+x out/linters/hadolint-$(HADOLINT_VERSION)


# END: lint-install ../crocodile/
