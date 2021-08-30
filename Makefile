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
